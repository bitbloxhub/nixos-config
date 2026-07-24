{
  flake-file.inputs = {
    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs = {
        cachix.follows = "";
        flake-compat.follows = "";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.inputs = {
          gitignore.follows = "gitignore";
          nixpkgs.follows = "nixpkgs";
        };
      };
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default.packages = [
        pkgs.cargo
        pkgs.rustc
        pkgs.rustfmt
        pkgs.rust-analyzer
      ];

      treefmt.programs.rustfmt.enable = true;
    };
}
