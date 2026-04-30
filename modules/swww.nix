{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.swww ];
      _.swww.homeManager =
        {
          lib,
          config,
          pkgs,
          ...
        }:
        lib.mkMerge [
          {
            home.packages = [
              pkgs.swww
            ];
          }

          (lib.mkIf (lib.attrByPath [ "programs" "niri" "settings" ] null config != null) {
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
          })
        ];
    };
}
