{
  description = "Python 3.10 development environment with custom Git config and PIP support";

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
          ipython
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
        ]);

        # Create a temporary gitconfig file
        gitConfigFile = pkgs.writeTextFile {
          name = "gitconfig";
          text = ''
            [user]
              name = alika
              email = python-dev@example.com
            [core]
              editor = vim
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
            echo "Python 3.10 development environment activated"
            echo "Python version: $(python --version)"
            
            # Set up temporary Git configuration for this shell
            export GIT_CONFIG_GLOBAL="${gitConfigFile}"
            echo "Custom Git configuration loaded"
            
            # Create and set up a virtual environment directory for editable installs
            export VIRTUAL_ENV_DISABLE_PROMPT=1
            export PYTHONPATH="$PWD:$PYTHONPATH"
            
            # Make pip install packages to the local directory
            export PIP_PREFIX="$PWD/.pip"
            export PYTHONPATH="$PIP_PREFIX/${pkgs.python310.sitePackages}:$PYTHONPATH"
            export PATH="$PIP_PREFIX/bin:$PATH"
            
            # Make Python tools find packages in development mode
            export PYTHONPATH="$PWD:$PYTHONPATH"
            
            echo "Development environment ready for editable installs (python -m pip install -e ./)"
          '';
        };
      }
    );
}