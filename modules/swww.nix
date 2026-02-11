{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.swww ];
      _.swww.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.swww
          ];

          programs.niri.settings = {
            spawn-at-startup = [
              {
                command = [
                  "swww-daemon"
                ];
              }
              {
                command = [
                  "swww"
                  "img"
                  "${./wallpapers/miku-v.jpg}"
                ];
              }
            ];
          };
        };
    };
}
