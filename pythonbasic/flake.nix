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
          ipympl
          ipykernel
          jupyter
          jupyterlab
          notebook
          pyautogui
          kiwisolver
          matplotlib
          matplotlib-inline
          numpy
          numpy-stl
          pandas
          pip # Ensure pip is explicitly included
          scipy
          setuptools # Needed for development installation
          setuptools-scm
          six
          svgwrite
          wheel # Useful for package building
          pyclipper
          pyyaml
          openpyxl
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
            pkgs.which
            pkgs.bashInteractive # Help with debugging path issues
          ];
          
          shellHook = ''
            # Create and set up a virtual environment directory for editable installs
            export VIRTUAL_ENV_DISABLE_PROMPT=1
            
            # Make pip install packages to the local directory
            mkdir -p .pip
            export PIP_PREFIX="$PWD/.pip"
            export PYTHONPATH="$PIP_PREFIX/${pkgs.python313.sitePackages}:$PYTHONPATH"
            export PATH="$PIP_PREFIX/bin:$PATH"
            
            # Make Python tools find packages in development mode
            export PYTHONPATH="$PWD:$PYTHONPATH"

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
            echo "1. Install Jupyter extension in VS Code if not already installed"
            echo "2. Open VS Code Command Palette (Ctrl+Shift+P)"
            echo "3. Select 'Jupyter: Connect to existing Jupyter server'"
            echo "4. Enter the URL printed above with the token"
            echo ""
            
            
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