{
  config,
  pkgs,
  system-manager,
  ...
}:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jonahgam";
  home.homeDirectory = "/home/jonahgam";

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";

  home.packages = [
    pkgs.nixfmt-rfc-style
    pkgs.stylua
    pkgs.delta
    pkgs.python3Packages.jupytext
    pkgs.basedpyright
    system-manager.packages."${pkgs.system}".default
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    monitor = ",eDP-1,auto,auto";
    env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "XDG_SESSION_TYPE,wayland"
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
    ];
    bind =
      [
        "$mod, F, exec, firefox"
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
    debug.disable_logs = false;
  };

  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;

  programs.neovim = {
    enable = true;
    extraPackages = [
      pkgs.imagemagick
    ];
    withPython3 = true;
    extraPython3Packages =
      ps: with ps; [
        pynvim
        jupyter-client
        cairosvg # for image rendering
        pnglatex # for image rendering
        plotly # for image rendering
        pyperclip
      ];
  };

  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  programs.wezterm.enable = true;
  home.file."./.config/wezterm/wezterm.lua".source = ./wezterm.lua;

  xdg.enable = true;
  xdg.mime.enable = true;
  targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
