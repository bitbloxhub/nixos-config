{
  lib,
  ...
}:
{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.swayosd ];
      _.swayosd.homeManager =
        {
          config,
          pkgs,
          ...
        }:
        lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
          home.packages = [ pkgs.swayosd ];
          programs.niri.settings.binds = {
            "XF86AudioLowerVolume".action.spawn = [
              (lib.getExe' pkgs.swayosd "swayosd-client")
              "--output-volume"
              "lower"
            ];
            "XF86AudioMicMute".action.spawn = [
              (lib.getExe' pkgs.swayosd "swayosd-client")
              "--input-volume"
              "mute-toggle"
            ];
            "XF86AudioMute".action.spawn = [
              (lib.getExe' pkgs.swayosd "swayosd-client")
              "--output-volume"
              "mute-toggle"
            ];
            "XF86AudioRaiseVolume".action.spawn-sh =
              "${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-mute @DEFAULT_SINK@ 0 && ${lib.getExe' pkgs.swayosd "swayosd-client"} --output-volume raise";
            "XF86MonBrightnessDown".action.spawn = [
              (lib.getExe' pkgs.swayosd "swayosd-client")
              "--brightness"
              "lower"
            ];
            "XF86MonBrightnessUp".action.spawn = [
              (lib.getExe' pkgs.swayosd "swayosd-client")
              "--brightness"
              "raise"
            ];
          };
          services.swayosd = {
            enable = true;
            stylePath = ./style.css;
            topMargin = 0.97;
          };

        };
    };
}
