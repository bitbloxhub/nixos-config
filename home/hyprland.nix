{
  pkgs,
  hostname,
  nvidia,
  ...
}:
{
  home.packages = with pkgs; [
    grimblast
    (writeShellScriptBin "hyprland-window-switch" (builtins.readFile ../scripts/hyprland-window-switch))
  ];

  services.hyprpaper.enable = true;
  services.hyprpaper.settings = {
    ipc = "on";
    splash = false;

    preload = [ "/home/jonahgam/.local/share/eog-wallpaper.png" ];
    wallpaper = [ ",/home/jonahgam/.local/share/eog-wallpaper.png" ];
  };

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    monitor =
      if (hostname == "extreme-creeper") then
        [
          ",preferred,auto,1"
          "WAYLAND-1,disable"
        ]
      else
        "";
    env =
      [
        "HYPRCURSOR_THEME, catppuccin-mocha-dark-cursors"
        "HYPRCURSOR_SIZE, 32"
      ]
      ++ (
        if nvidia then
          [
            "LIBVA_DRIVER_NAME,nvidia"
            "XDG_SESSION_TYPE,wayland"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          ]
        else
          [ ]
      );
    exec-once = [
      "waybar"
    ];
    bind =
      [
        "$mod, F, exec, firefox"
        "$mod, T, exec, wezterm"
        "$mod, M, fullscreen, 1"
        "$mod SHIFT, M, fullscreen, 0"
        "$mod, H, exec, fuzzel"
        "ALT, Tab, exec, hyprland-window-switch"
        "CTRL ALT, Delete, exec, hyprctl dispatch exit 0"
        ", Print, exec, grimblast copy area"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9
        )
      );
    binde = [
      ", XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86MonBrightnessUp, exec, light -A 4.95"
      ", XF86MonBrightnessDown, exec, light -U 4.95"
    ];
    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ];
    windowrulev2 = [
      "maximize, class:.*"
      "prop immediate, fullscreen:1, class: (com.mojang.minecraft)"
    ];
    general = {
      gaps_in = 5;
      gaps_out = 10;
      allow_tearing = true;
    };
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      exit_window_retains_fullscreen = true;
    };
    input.touchpad.tap-to-click = false;
    group = {
      groupbar.enabled = true;
    };
    ecosystem = {
      no_update_news = true;
      no_donation_nag = true;
    };
    debug.disable_logs = false;
  };
}
