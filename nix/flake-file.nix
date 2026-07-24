{
  inputs,
  ...
}:
{
  flake-file = {
    inputs = {
      flake-file.url = "github:vic/flake-file";
      crane.url = "github:ipetkov/crane";
      flake-aspects.url = "github:vic/flake-aspects";
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      flake-utils = {
        url = "github:numtide/flake-utils";
        inputs.systems.follows = "systems";
      };
      flint = {
        url = "github:NotAShelf/flint";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      import-tree.url = "github:vic/import-tree";
      lib-aggregate = {
        url = "github:nix-community/lib-aggregate";
        inputs = {
          flake-utils.follows = "flake-utils";
          nixpkgs-lib.follows = "nixpkgs";
        };
      };
      nix-bwrapper = {
        url = "github:Naxdy/nix-bwrapper";
        inputs = {
          nixpkgs.follows = "nixpkgs";
          nuschtosSearch.follows = "";
          treefmt-nix.follows = "treefmt-nix";
        };
      };
      nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      systems.url = "github:nix-systems/default";
    };
    outputs =
      # nix
      ''
        inputs:
        inputs.flake-parts.lib.mkFlake { inherit inputs; } (
          (inputs.import-tree.filterNot (inputs.nixpkgs.lib.hasSuffix "npins/default.nix")) ./nix
        )
      '';
  };

  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.import-tree
    inputs.flake-parts.flakeModules.modules
    inputs.flake-aspects.flakeModule
  ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
}
