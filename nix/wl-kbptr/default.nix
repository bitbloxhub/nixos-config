{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.wl-kbptr ];
      _.wl-kbptr.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.wl-kbptr
          ];

          xdg.configFile."wl-kbptr/config".source = ./config;
        };
    };
}
