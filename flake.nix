{
  description = "system configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix/main";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      catppuccin,
      home-manager,
      system-manager,
      nix-system-graphics,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos-bill = nixpkgs.lib.nixosSystem {
        system = "x86_64_linux";
        modules = [
          catppuccin.nixosModules.catppuccin
          ./hosts/nixos-bill
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.jonahgam = {
              imports = [
                ./home.nix
                catppuccin.homeManagerModules.catppuccin
              ];
            };
          }
        ];
      };
      systemConfigs = {
        extreme-creeper = system-manager.lib.makeSystemConfig {
          modules = [
            nix-system-graphics.systemModules.default
            (
              let
                pkgs = import nixpkgs {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              in
              {
                config = {
                  nixpkgs.hostPlatform = "x86_64-linux";
                  system-manager.allowAnyDistro = true;
                  system-graphics.enable = true;
                  system-graphics.package = pkgs.linuxPackages.nvidia_x11_beta.override {
                    libsOnly = true;
                    kernel = null;
                  };
                };
              }
            )
          ];
        };
      };
      homeConfigurations = {
        "jonahgam@extreme-creeper" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit system-manager;
          };
          modules = [
            ./new-home.nix
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      };
    };
}
