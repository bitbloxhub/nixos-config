{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.waybar = {
      enable = lib.my.mkDisableOption "waybar";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.waybar.enable = config.my.programs.waybar.enable;
      programs.waybar.style = builtins.readFile ./waybar.css;
      programs.waybar.settings = [
        {
          layer = "top";
          position = "bottom";
          output = [ "eDP-1" ];
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "pulseaudio"
            "battery"
            "clock"
          ];
        }
      ];
    };
}
