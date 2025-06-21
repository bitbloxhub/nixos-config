{
  description = "system configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      catppuccin,
      home-manager,
      system-manager,
      nix-system-graphics,
      nixCats,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      flake =
        let
          mapFromHosts =
            { type, constructor }:
            (builtins.listToAttrs (
              builtins.filter (x: x != null) (
                builtins.map (
                  host: if builtins.pathExists ./hosts/${host}/${type}.nix then (constructor host) else null
                ) (builtins.attrNames (builtins.readDir ./hosts))
              )
            ));
        in
        {
          nixosConfigurations = mapFromHosts {
            type = "nixos";
            constructor = host: {
              name = host;
              value = (
                nixpkgs.lib.nixosSystem {
                  modules = [ ./hosts/${host}/nixos.nix ];
                }
              );
            };
          };
          systemConfigs = mapFromHosts {
            type = "system-manager";
            constructor = host: {
              name = host;
              value = (
                system-manager.lib.makeSystemConfig {
                  extraSpecialArgs = { inherit (inputs) nix-system-graphics; };
                  modules = [ ./hosts/${host}/system-manager.nix ];
                }
              );
            };
          };
          homeConfigurations = mapFromHosts {
            type = "home";
            constructor = host: {
              name = "${(import ./hosts/${host}/home-meta.nix).username}@${host}";
              value = (
                home-manager.lib.homeManagerConfiguration {
                  extraSpecialArgs = {
                    inherit
                      system-manager
                      catppuccin
                      nixCats
                      inputs
                      ;
                  } // (import ./hosts/${host}/home-meta.nix);
                  pkgs = nixpkgs.legacyPackages.${(import ./hosts/${host}/home-meta.nix).system};
                  modules = [ ./hosts/${host}/home.nix ];
                }
              );
            };
          };
        };
    };
}
