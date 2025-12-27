{
  lib,
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "allowedUnfreePackages";

  options.allowedUnfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  nixos.always =
    {
      config,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) config.my.allowedUnfreePackages;
    };

  homeManager.always =
    {
      config,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) config.my.allowedUnfreePackages;
    };

  systemManager.always =
    {
      config,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) config.my.allowedUnfreePackages;
    };
}
