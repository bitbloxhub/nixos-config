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
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs =
    {
      self,
      nixpkgs,
      catppuccin,
      home-manager,
      system-manager,
      nix-system-graphics,
      nixCats,
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
                ./old-home.nix
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
            #"${nixpkgs}/nixos/modules/security/pam.nix"
            #"${nixpkgs}/nixos/modules/config/system-environment.nix"
            #"${nixpkgs}/nixos/modules/programs/wayland/uwsm.nix"
            #"${nixpkgs}/nixos/modules/programs/xwayland.nix"
            #"${nixpkgs}/nixos/modules/programs/dconf.nix"
            #"${nixpkgs}/nixos/modules/programs/wayland/hyprland.nix"
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
                  #programs.hyprland.enable = true;
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
            inherit system-manager inputs;
          };
          modules = [
            ./home.nix
            catppuccin.homeManagerModules.catppuccin
            nixCats.homeModule
          ];
        };
      };
    };
}
