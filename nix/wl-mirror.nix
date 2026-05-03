{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.wl-mirror ];
      _.wl-mirror.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.wl-mirror
          ];
        };
    };
}
