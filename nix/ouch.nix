{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.ouch ];
      _.ouch.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.ouch
          ];
        };
    };
}
