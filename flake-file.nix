{
  inputs,
  ...
}:
{
  imports = [
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";

    flint = {
      url = "github:NotAShelf/flint";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";

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

    not-denix = {
      url = "github:bitbloxhub/not-denix";
      inputs = {
        actions-nix.follows = "actions-nix";
        flake-file.follows = "flake-file";
        flake-parts.follows = "flake-parts";
        flint.follows = "flint";
        git-hooks.follows = "git-hooks";
        import-tree.follows = "import-tree";
        make-shell.follows = "make-shell";
        nix-auto-ci.follows = "nix-auto-ci";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
