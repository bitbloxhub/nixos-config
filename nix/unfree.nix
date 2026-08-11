{
  lib,
  ...
}:
{
  flake.grove = {
    types = {
      host.options.unfree = lib.mkOption {
        default = { };
        type = lib.types.submodule {
          options.packages = lib.mkOption {
            default = [ ];
            type = lib.types.listOf lib.types.str;
          };
        };
      };
      user.options.unfree = lib.mkOption {
        default = { };
        type = lib.types.submodule {
          options.packages = lib.mkOption {
            default = [ ];
            type = lib.types.listOf lib.types.str;
          };
        };
      };
    };
    projectors = {
      host = {
        nixos = host: {
          nixpkgs.config.allowUnfreePredicate =
            pkg: builtins.elem (lib.getName pkg) host.config.unfree.packages;
        };
        systemManager = host: {
          nixpkgs.config.allowUnfreePredicate =
            pkg: builtins.elem (lib.getName pkg) host.config.unfree.packages;
        };
      };
      user.homeManager = user: {
        nixpkgs.config.allowUnfreePredicate =
          pkg: builtins.elem (lib.getName pkg) user.config.unfree.packages;
      };
    };
  };
}
