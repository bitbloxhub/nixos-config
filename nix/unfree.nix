{
  lib,
  ...
}:
{
  flake.aspects.system =
    let
      unfreeModule =
        { config, ... }:
        {
          config.nixpkgs.config.allowUnfreePredicate =
            pkg: builtins.elem (lib.getName pkg) config.unfree.packages;
          options.unfree.packages = lib.mkOption {
            default = [ ];
            type = lib.types.listOf lib.types.str;
          };
        };
    in
    {
      _.unfree = unfreePackages: {
        homeManager.unfree.packages = unfreePackages;
        nixos.unfree.packages = unfreePackages;
        systemManager.unfree.packages = unfreePackages;
      };
      homeManager = unfreeModule;
      nixos = unfreeModule;
      systemManager = unfreeModule;
    };
}
