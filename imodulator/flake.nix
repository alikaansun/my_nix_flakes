{
  description = "Python 3.12 development environment with custom Git config and PIP support";

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
        
        pythonEnv = pkgs.python312.withPackages (ps: with ps; [
          backcall
          cycler
          decorator
          fonttools
          # ipython
          jedi
          kiwisolver
          matplotlib
          matplotlib-inline
          numpy
          packaging
          pandas
          parso
          pexpect
          pickleshare
          pillow
          pip # Ensure pip is explicitly included
          prompt-toolkit
          ptyprocess
          pygments
          pyparsing
          python-dateutil
          pytz
          scipy
          setuptools # Needed for development installation
          setuptools-scm
          six
          svgwrite
          tomli
          traitlets
          wcwidth
          wheel # Useful for package building
          # Add dependencies for nazca if known
          pyclipper
          pyyaml
          openpyxl
        ]);

        # Create a temporary gitconfig file
        gitConfigFile = pkgs.writeTextFile {
          name = "gitconfig";
          text = ''
            [user]
              name = Kaan
              email = a.k.sunnetcioglu@tue.nl
              # pull.rebase true
            [init]
              defaultBranch = main
            [color]
              ui = auto
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
            pkgs.git
            pkgs.bashInteractive
            pkgs.klayout
          ];
          
          shellHook = ''
            echo "Python 3.12 development environment activated"
            echo "Python version: $(python --version)"
            
            # Set up temporary Git configuration for this shell
            export GIT_CONFIG_GLOBAL="${gitConfigFile}"
            git config pull.rebase true
            echo "Custom Git configuration loaded"

            
            # Create and set up a virtual environment directory for editable installs
            export VIRTUAL_ENV_DISABLE_PROMPT=1
            
            # Make pip install packages to the local directory
            mkdir -p .pip
            export PIP_PREFIX="$PWD/.pip"
            export PYTHONPATH="$PIP_PREFIX/${pkgs.python312.sitePackages}:$PYTHONPATH"
            export PATH="$PIP_PREFIX/bin:$PATH"
            
            # Make Python tools find packages in development mode
            export PYTHONPATH="$PWD:$PYTHONPATH"

            # Set up KLayout Python integration
            KLAYOUT_PATH=$(which klayout)
            KLAYOUT_DIR=$(dirname "$KLAYOUT_PATH")
            if [ -d "$KLAYOUT_DIR/../lib/pymod" ]; then
              export KLAYOUT_PYTHONPATH="$KLAYOUT_DIR/../lib/pymod"
              export PYTHONPATH="$KLAYOUT_PYTHONPATH:$PYTHONPATH"
              echo "KLayout Python modules available at $KLAYOUT_PYTHONPATH"
            else
              echo "Warning: KLayout Python modules not found at $KLAYOUT_DIR/../lib/pymod"
              
              # Try the alternative location as fallback
              if [ -d "$KLAYOUT_DIR/../lib/python" ]; then
                export KLAYOUT_PYTHONPATH="$KLAYOUT_DIR/../lib/python"
                export PYTHONPATH="$KLAYOUT_PYTHONPATH:$PYTHONPATH"
                echo "KLayout Python modules available at $KLAYOUT_PYTHONPATH"
              else
                echo "Warning: KLayout Python modules not found"
              fi
            fi

            # Install nazca in development mode if it exists
            NAZCA_PATH=~/Documents/Apps/nazca-0.6.1
            NAZCAIMOS_PATH=~/Documents/Repos/nazca_imos
      
            # Check if nazca is already installed
            if python -c "import nazca" &>/dev/null; then
              NAZCA_VERSION=$(python -c "import nazca; print(nazca.__version__)")
              echo "Nazca is already installed (version $NAZCA_VERSION)"
            else
              if [ -d "$NAZCA_PATH" ]; then
                echo "Installing nazca from $NAZCA_PATH"
                pip install "$NAZCA_PATH"
                python -c "import nazca; print(f'Nazca {nazca.__version__} successfully imported')"
              else
                echo "Warning: Nazca path not found: $NAZCA_PATH"
              fi
            fi
            
            # Launch VSCode in the nazca_imos directory
            echo "Opening VSCode in $NAZCAIMOS_PATH"
            code $NAZCAIMOS_PATH &
            cd "$NAZCAIMOS_PATH"
            # Check if nazca_imos is already installed
            if python -c "import nazca_imos" &>/dev/null; then
              NAZCA_IMOS_VERSION=$(python -c "import nazca_imos; print(nazca_imos.__version__)")
              echo "Nazca imos is already installed (version $NAZCA_IMOS_VERSION)"
            else
              echo "Installing nazca_imos from $NAZCAIMOS_PATH"
              python -m pip install -e .
              python -c "import nazca_imos; print(f'Nazca imos successfully imported')"
            fi
            # echo "Installing nazca_imos from $NAZCAIMOS_PATH"
            # python -m pip install -e .
            # python -c "import nazca_imos; print(f'Nazca imos successfully imported')"
            # echo "Development environment ready"
          '';
        };
      }
    );
}