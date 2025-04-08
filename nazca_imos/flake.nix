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
        ]);

        # Create a temporary gitconfig file
        gitConfigFile = pkgs.writeTextFile {
          name = "gitconfig";
          text = ''
            [user]
              name = alika
              email = python-dev@example.com
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
            
            # Install nazca in development mode if it exists
            NAZCA_PATH=~/Documents/Apps/nazca-0.6.1
            if [ -d "$NAZCA_PATH" ]; then
              echo "Installing nazca from $NAZCA_PATH"
              cd "$NAZCA_PATH"
              python -m pip install -e .
              cd -
              python -c "import nazca; print(f'Nazca {nazca.__version__} successfully imported')"
            else
              echo "Warning: Nazca path not found: $NAZCA_PATH"
            fi
            
            # Launch VSCode in the nazca_imos directory
            echo "Opening VSCode in /home/alik/Documents/Repos/nazca_imos"
            code /home/alik/Documents/Repos/nazca_imos &

            echo "Development environment ready"
          '';
        };
      }
    );
}