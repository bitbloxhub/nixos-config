{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.swww = {
      enable = lib.my.mkDisableOption "swww";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      lib,
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
              "sh"
              "-c"
              "sleep 2 && swww img ${./wallpapers/miku-hacker0.jpg}"
            ];
          }
        ];
      };
    };
}
