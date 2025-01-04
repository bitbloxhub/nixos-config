{
  description = "system configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix/main";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      catppuccin,
      home-manager,
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
      homeConfigurations = {
        "jonahgam@extreme-creeper" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./new-home.nix
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      };
    };
}
