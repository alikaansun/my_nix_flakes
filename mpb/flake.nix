{
  description = "Python for basic tasks";

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
        
        pythonEnv = pkgs.python313.withPackages (ps: with ps; [
          decorator
          ipython
          ipykernel
          jupyter
          jupyterlab
          notebook
          matplotlib
          matplotlib-inline
          numpy
          pandas
          pip # Ensure pip is explicitly included
          scipy
          setuptools # Needed for development installation
          setuptools-scm
          six
          svgwrite
          wheel # Useful for package building
          pyyaml
          meep
          # h5py
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
            pkgs.which # Help with debugging path issues
            pkgs.mpb
            pkgs.h5utils
            pkgs.bashInteractive
          ];
          
          shellHook = ''
            echo "Python basic development environment activated"
            echo "Python version: $(python --version)"
          
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
            echo "Select 'Jupyter: Connect to existing Jupyter server'"
            echo "Enter the URL printed above with the token"
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