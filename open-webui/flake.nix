{
  description = "NixOS configuration with Ollama and Open WebUI";

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
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            curl
          ];
          
          shellHook = ''
            echo "Ollama & Open WebUI development environment"
            echo "Use this module in your NixOS configuration by adding it to your imports"
          '';
        };
      }
    ) // {
      # Define the NixOS module
      nixosModules.default = { pkgs, lib, config, ... }: {
        # Enable unfree packages (required for CUDA)
        nixpkgs.config.allowUnfree = true;

        # Enable Ollama service with CUDA acceleration
        services.ollama = {
          enable = true;
          acceleration = "cuda";
        };
        
        # Enable Open WebUI service
        services.open-webui.enable = true;

        # Firewall settings to allow Open WebUI and Ollama communication
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ 
            3000  # Default Open WebUI port
            8080  # Alternate port
            11434 # Default Ollama API port
          ];
        };
      };
    };
}