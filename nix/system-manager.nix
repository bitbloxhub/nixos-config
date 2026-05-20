{
  lib,
  flake-parts-lib,
  ...
}:
{
  config.flake-file.inputs.system-manager = {
    url = "github:numtide/system-manager";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-compat.follows = "";
      userborn = {
        inputs = {
          nixpkgs.follows = "nixpkgs";
          flake-parts.follows = "flake-parts";
          systems.follows = "systems";
          pre-commit-hooks-nix.inputs = {
            gitignore.follows = "gitignore";
            nixpkgs.follows = "nixpkgs";
          };
        };
      };
    };
  };

  # TODO: move this somewhere else
  config.flake-file.inputs.nix-system-graphics = {
    url = "github:soupglasses/nix-system-graphics";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  options.flake = flake-parts-lib.mkSubmoduleOptions {
    systemConfigs = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = ''
        Instantiated system-manager configurations.
      '';
    };
  };
}
