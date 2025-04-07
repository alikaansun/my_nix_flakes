{
  description = "NixOS configuration with Ollama and Open WebUI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem 
    (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      nixosConfigurations.ollama-system = nixpkgs.lib.nixosSystem 
      {  
        modules = [
          ({ pkgs, lib, config, ... }: 
          {
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
          })
        ];
      };
    
    );
}