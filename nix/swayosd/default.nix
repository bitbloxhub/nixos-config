{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.swayosd.enable = self.lib.mkDisableOption "swayosd";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf (user.config.swayosd.enable && user.config.niri.enable) {
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
        xdg.configFile."swayosd/config.toml".source = (pkgs.formats.toml { }).generate "swayosd-config" {
          server.show_percentage = true;
        };
      };
  };
}
