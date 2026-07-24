{
  lib,
  flake-parts-lib,
  ...
}:
{
  config.flake-file.inputs = {
    # TODO: move this somewhere else
    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
        userborn.inputs = {
          flake-parts.follows = "flake-parts";
          nixpkgs.follows = "nixpkgs";
          pre-commit-hooks-nix.inputs = {
            gitignore.follows = "gitignore";
            nixpkgs.follows = "nixpkgs";
          };
          systems.follows = "systems";
        };
      };
    };
  };

  options.flake = flake-parts-lib.mkSubmoduleOptions {
    systemConfigs = lib.mkOption {
      default = { };
      description = ''
        Instantiated system-manager configurations.
      '';
      type = lib.types.lazyAttrsOf lib.types.raw;
    };
  };
}
