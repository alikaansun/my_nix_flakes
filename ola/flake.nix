{
  description = "Python 3.11 development environment for ola project with Jupyter notebook support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        
        pythonEnv = pkgs.python311.withPackages (ps: with ps; [
          # Core Python packages from your environment.yml
          numpy
          pandas
          matplotlib
          seaborn
          scikit-rf
          
          # Jupyter and IPython packages
          ipython
          ipykernel
          jupyter
          jupyterlab
          notebook
          jupyter-client
          jupyter-core
          
          # Additional dependencies
          asttokens
          pip
          setuptools
          wheel
          
          # Common scientific packages
          scipy
          matplotlib-inline
          
          # Note: pywin32 is Windows-specific and not needed on Linux/macOS
          # ipympl might need to be installed via pip in the shell hook if not available in nixpkgs
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
            pkgs.which
            pkgs.bashInteractive
          ];
          
          shellHook = ''
            echo "Ola project development environment activated"
            echo "Python version: $(python --version)"

            # Install ipympl if not available in nixpkgs
            pip install --user ipympl
            
            # Create a directory for Jupyter notebooks if it doesn't exist
            mkdir -p notebooks
            
            # Start Jupyter server in the background
            echo "Starting Jupyter server..."
            jupyter notebook --no-browser --ip=127.0.0.1 --notebook-dir=./notebooks &
            JUPYTER_PID=$!
            
            # Give Jupyter a moment to start
            sleep 2
            
            # Display Jupyter server info
            echo "Jupyter server is running at http://127.0.0.1:8888/"
            echo "You can connect to this server from VS Code:"
            echo "1. Install Jupyter extension in VS Code if not already installed"
            echo "2. Open VS Code Command Palette (Ctrl+Shift+P)"
            echo "3. Select 'Jupyter: Connect to existing Jupyter server'"
            echo "4. Enter the URL printed above with the token"
            echo ""
            
            # Launch VSCode
            echo "Opening VSCode"
            code . &
            
            # Define cleanup function
            cleanup() {
              echo "Shutting down Jupyter server (PID: $JUPYTER_PID)..."
              kill $JUPYTER_PID 2>/dev/null || true
              echo "Jupyter server stopped"
            }
            
            # Register cleanup on exit
            trap cleanup EXIT
            
            echo "Development environment ready"
          '';
        };
      }
    );
}