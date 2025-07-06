{
  description = "system configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

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
      import-tree,
      catppuccin,
      home-manager,
      system-manager,
      nix-system-graphics,
      nixCats,
      ...
    }:
    let
      lib = nixpkgs.lib.extend (lib: _: { my = (import ./lib { inherit inputs lib; }); });
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = { inherit lib; };
      }
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        imports = [
          flake-parts.flakeModules.modules
          inputs.home-manager.flakeModules.home-manager
          {
            options.flake = flake-parts.lib.mkSubmoduleOptions {
              systemConfigs = lib.mkOption {
                type = lib.types.lazyAttrsOf lib.types.raw;
                default = { };
                description = ''
                  Instantiated system-manager configurations.
                '';
              };
            };
          }
          (import-tree ./modules)
          ((import-tree.filter (lib.hasSuffix "default.nix")) ./hosts)
        ];

        flake = {
          inherit lib;
        };
      };
}
