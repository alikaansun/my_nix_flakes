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
          kiwisolver
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
          pyclipper
          pyyaml
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
          ];
          
          shellHook = ''
            echo "Python basic development environment activated"
            echo "Python version: $(python --version)"
          
            
            # Launch VSCode
            echo "Opening VSCode"
            code &

            echo "Development environment ready"
          '';
        };
      }
    );
}