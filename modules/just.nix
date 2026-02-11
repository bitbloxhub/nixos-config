{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.just
        ];
      };
    };

  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.just ];
      _.just.homeManager =
        {
          pkgs,
          ...
        }:
        {
          config.home.packages = [
            (pkgs.writeShellScriptBin "sjust" ''
              ${pkgs.just}/bin/just --justfile ${../Justfile} --working-directory ~/nixos-config/
            '')
          ];
        };
    };
}
