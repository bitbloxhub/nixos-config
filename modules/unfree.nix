{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.allowedUnfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  flake.modules.nixos.default =
    {
      config,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) config.my.allowedUnfreePackages;
    };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) config.my.allowedUnfreePackages;
    };

  flake.modules.systemManager.default =
    {
      config,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) config.my.allowedUnfreePackages;
    };
}
