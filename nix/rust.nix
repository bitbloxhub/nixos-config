{
  flake-file.inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";

    crate2nix = {
      url = "github:jrobsonchase/crate2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "";
      inputs.flake-parts.follows = "flake-parts";
      inputs.cachix.follows = "";
    };
  };

  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    {
      make-shells.default = {
        packages = [
          inputs'.fenix.packages.default.toolchain
          pkgs.rust-analyzer
        ];
      };

      treefmt = {
        programs.rustfmt.enable = true;
      };
    };
}
