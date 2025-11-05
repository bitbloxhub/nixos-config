{
  lib,
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.swww = {
      enable = self.lib.mkDisableOption "swww";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = lib.mkIf config.my.programs.swww.enable [
        pkgs.swww
      ];

      programs.niri.settings = {
        spawn-at-startup = lib.mkIf config.my.programs.swww.enable [
          {
            command = [
              "swww-daemon"
            ];
          }
          {
            command = [
              "swww"
              "img"
              "${./wallpapers/miku-polygons.jpg}"
            ];
          }
        ];
      };
    };
}
