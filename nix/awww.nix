{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.awww ];
      _.awww.homeManager =
        {
          lib,
          config,
          pkgs,
          ...
        }:
        lib.mkMerge [
          {
            home.packages = [
              pkgs.awww
            ];
          }

          (lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
            programs.niri.settings.spawn-at-startup = [
              {
                command = [
                  "awww-daemon"
                ];
              }
              {
                command = [
                  "awww"
                  "img"
                  "${./wallpapers/miku-v.jpg}"
                ];
              }
            ];
          })
        ];
    };
}
