{
  inputs,
  ...
}:
{
  flake-file = {
    outputs =
      # nix
      ''
        inputs:
        inputs.flake-parts.lib.mkFlake { inherit inputs; } (
          (inputs.import-tree.filterNot (inputs.nixpkgs.lib.hasSuffix "npins/default.nix")) ./nix
        )
      '';
    inputs = {
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      flake-file.url = "github:vic/flake-file";
      flake-aspects.url = "github:vic/flake-aspects";
      import-tree.url = "github:vic/import-tree";

      flint = {
        url = "github:NotAShelf/flint";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nix-bwrapper = {
        url = "github:Naxdy/nix-bwrapper";
        inputs = {
          nixpkgs.follows = "nixpkgs";
          treefmt-nix.follows = "treefmt-nix";
          nuschtosSearch.follows = "";
        };
      };

      systems.url = "github:nix-systems/default";

      flake-utils = {
        url = "github:numtide/flake-utils";
        inputs.systems.follows = "systems";
      };

      lib-aggregate = {
        url = "github:nix-community/lib-aggregate";
        inputs = {
          flake-utils.follows = "flake-utils";
          nixpkgs-lib.follows = "nixpkgs";
        };
      };

      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

      nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

      home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.import-tree
    inputs.flake-parts.flakeModules.modules
    inputs.flake-aspects.flakeModule
  ];
}
