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
          options.unfree = {
            packages = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };
          };
          config.nixpkgs.config.allowUnfreePredicate =
            pkg: builtins.elem (lib.getName pkg) config.unfree.packages;
        };
    in
    {
      nixos = unfreeModule;
      homeManager = unfreeModule;
      systemManager = unfreeModule;

      _.unfree = unfreePackages: {
        nixos = {
          unfree.packages = unfreePackages;
        };
        homeManager = {
          unfree.packages = unfreePackages;
        };
        systemManager = {
          unfree.packages = unfreePackages;
        };
      };
    };
}
