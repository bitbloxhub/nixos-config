{
  programs.waybar.enable = true;
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
}
