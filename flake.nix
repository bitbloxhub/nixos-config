{
  description = "system configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    deploy-rs = {
      url = "github:isabelroses/deploy-rs/no-fu";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
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
      nixCats,
      deploy-rs,
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
            ./hosts/extreme-creeper/system-manager.nix
          ];
        };
      };
      homeConfigurations = {
        "jonahgam@extreme-creeper" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit system-manager inputs;
            nvidia = true;
            hostname = "extreme-creeper";
          };
          modules = [
            ./hosts/extreme-creeper/home.nix
            catppuccin.homeManagerModules.catppuccin
            nixCats.homeModule
          ];
        };
      };
      
      deploy.nodes.extreme-creeper = {
        hostname = "localhost";
        sshUser = "jonahgam";
        user = "root";
        interactiveSudo = true;
        sshOpts = [ "-vvv" "-p 10022" "-oControlMaster=no" ];
        fastConnection = true;
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.custom self.systemConfigs.extreme-creeper "sudo ./bin/activate";
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
