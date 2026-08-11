{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.awww.enable = self.lib.mkDisableOption "awww";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.awww.enable (
        lib.mkMerge [
          {
            home.packages = [ pkgs.awww ];
          }
          (lib.mkIf user.config.niri.enable {
            programs.niri.settings.spawn-at-startup = [
              {
                command = [ "awww-daemon" ];
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
        ]
      );
  };
}
