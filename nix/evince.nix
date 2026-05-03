{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.evince ];
      _.evince.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.evince
          ];
        };
    };
}
