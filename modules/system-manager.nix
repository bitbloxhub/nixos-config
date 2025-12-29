{
  lib,
  flake-parts-lib,
  ...
}:
{
  config.flake-file.inputs.system-manager = {
    url = "github:numtide/system-manager";
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
