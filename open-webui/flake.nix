{
description = "NixOS configuration with Ollama and Open WebUI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    {
      nixosConfigurations.ollama-system = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, lib, ... }: 
          {

            # Enable Ollama service with CUDA acceleration
            services.ollama = {
              enable = true;
              acceleration = "cuda";
            };

            # Enable Open WebUI service
            services.open-webui.enable = true;

          })
          ];  
          };
    };
}