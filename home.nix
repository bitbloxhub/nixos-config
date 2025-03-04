{
  inputs,
  config,
  pkgs,
  system-manager,
  hyprswitch,
  nvidia,
  hostname,
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
    pkgs.grimblast
    (pkgs.writeShellScriptBin "hyprland-window-switch" (
      builtins.readFile ./scripts/hyprland-window-switch
    ))
    system-manager.packages."${pkgs.system}".default
  ];

  services.hyprpaper.enable = true;
  services.hyprpaper.settings = {
    ipc = "on";
    splash = false;

    preload = [ "/home/jonahgam/.local/share/eog-wallpaper.png" ];
    wallpaper = [ ",/home/jonahgam/.local/share/eog-wallpaper.png" ];
  };

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
      if nvidia then
        [
          "LIBVA_DRIVER_NAME,nvidia"
          "XDG_SESSION_TYPE,wayland"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ]
      else
        [ ];
    exec-once = [
      "waybar"
    ];
    bind =
      [
        "$mod, F, exec, firefox"
        "$mod, T, exec, wezterm"
        "$mod, M, fullscreen, 1"
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
    windowrulev2 = [
      "maximize, class:.*"
    ];
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

  programs.fuzzel = {
    enable = true;
    settings.main = {
      font = "Fira Code:size=10";
      lines = 20;
      width = 60;
      horizontal-pad = 40;
      vertical-pad = 16;
      inner-pad = 6;
    };
  };

  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;

  programs.neovim = {
    enable = false;
  };

  #home.file."./.config/nvim/" = {
  #  source = ./nvim;
  #  recursive = true;
  #};

  nixCats = {
    enable = true;
    nixpkgs_version = inputs.nixpkgs;
    luaPath = "${./nvim}";
    packageNames = [ "nvim" ];
    categoryDefinitions.replace = (
      {
        pkgs,
        settings,
        categories,
        name,
        ...
      }@packageDef:
      {
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            pkgs.python3Packages.jupytext
            basedpyright
            ruff
            lua-language-server
          ];
        };
        extraPython3Packages = {
          general =
            ps: with ps; [
              pynvim
              jupyter-client
              cairosvg # for image rendering
              pnglatex # for image rendering
              plotly # for image rendering
              pyperclip
            ];
        };
        startupPlugins = {
          general =
            let
              animotion-nvim = pkgs.vimUtils.buildVimPlugin {
                name = "AniMotion.nvim";
                src = builtins.fetchGit {
                  url = "https://github.com/luiscassih/AniMotion.nvim.git";
                  rev = "a1adf214e276fa8c3f439ce3fa13a6f647744dab";
                };
              };
            in
            with pkgs.vimPlugins;
            [
              mini-nvim
              catppuccin-nvim
              fidget-nvim
              nvim-lspconfig
              nvim-treesitter.withAllGrammars
              blink-cmp
              direnv-vim
              neo-tree-nvim
              fzf-lua
              render-markdown-nvim
              image-nvim
              snacks-nvim
              edgy-nvim
              flatten-nvim
              molten-nvim
              jupytext-nvim
              otter-nvim
              quarto-nvim
              git-conflict-nvim
              precognition-nvim
              hardtime-nvim
              animotion-nvim
            ];
        };
      }
    );
    packageDefinitions.replace = {
      nvim =
        { pkgs, ... }:
        {
          settings = {
            wrapRc = true;
            configDirName = "nvim";
            withPython3 = true;
          };
          categories = {
            general = true;
          };
        };
    };
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
