{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
  };

  perSystem = {
    treefmt.programs.qmlformat.enable = true;
  };

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.noctalia ];
      _.noctalia.homeManager =
        {
          lib,
          pkgs,
          config,
          ...
        }:
        {
          imports = [ inputs.noctalia.homeModules.default ];
          config = lib.mkMerge [
            {
              programs.noctalia-shell = {
                enable = true;
                package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
                  patches = (old.patches or [ ]) ++ [
                    (pkgs.fetchpatch {
                      url = "https://github.com/noctalia-dev/noctalia-shell/commit/47123356323a096190f907f23870ce286c62c3f8.patch";
                      hash = "sha256-OjN+qsfm4suKTMDHxhbto3eJxsZwqvf+q9OhYqC34ns=";
                    })
                  ];
                });
                settings = {
                  ui = {
                    fontDefault = "Fira Code";
                    fontFixed = "Fira Code";
                  };
                  wallpaper = {
                    enabled = false; # use swww
                    enableLockScreenWallpaper = true;
                    lockScreenWallpaperLight = "${../wallpapers/niri-pool.png}";
                    lockScreenWallpaperDark = "${../wallpapers/niri-pool.png}";
                  };
                  network = {
                    disableDiscoverability = true;
                    bluetoothAutoConnect = false;
                  };
                  dock.enabled = false;
                  bar = {
                    useSeparateOpacity = true;
                    backgroundOpacity = 0;
                    outerCorners = false;
                    widgets = {
                      left = [
                        {
                          id = "Workspace";
                        }
                        {
                          id = "SystemMonitor";
                        }
                        {
                          id = "ActiveWindow";
                          maxWidth = 300;
                          useFixedWidth = true;
                        }
                      ];
                      center = [
                        {
                          id = "Clock";
                          formatHorizontal = "yyyy-MM-dd h:mm AP t";
                        }
                        {
                          id = "MediaMini";
                          maxWidth = 300;
                          useFixedWidth = true;
                          showVisualizer = true;
                          visualizerType = "mirrored";
                        }
                        {
                          id = "plugin:local-clock";
                          formatHorizontal = "yyyy-MM-dd h:mm AP t";
                        }
                      ];
                      right = [
                        {
                          id = "Tray";
                          drawerEnabled = false;
                          hidePassive = true;
                          blacklist = [
                            "nm-applet"
                          ];
                        }
                        {
                          id = "NotificationHistory";
                        }
                        {
                          id = "Battery";
                          displayMode = "icon-always";
                        }
                        {
                          id = "Volume";
                          displayMode = "alwaysShow";
                        }
                        {
                          id = "Brightness";
                          displayMode = "alwaysShow";
                        }
                        {
                          id = "ControlCenter";
                        }
                      ];
                    };
                  };
                  osd = {
                    location = "bottom_center";
                  };
                  idle = {
                    enabled = true;
                    # screenOffTimeout = 600;
                    # lockTimeout = 660;
                    # suspendTimeout = 1800;
                    # fadeDuration = 5;
                  };
                  colorSchemes = {
                    predefinedScheme = "Catppuccin";
                  };
                };
                plugins = {
                  states = {
                    local-clock = {
                      enabled = true;
                    };
                  };
                  version = 2;
                };
              };

              xdg.configFile."noctalia/plugins/local-clock" = {
                source = ./local-clock;
                recursive = true;
              };
            }

            (lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
              programs.niri.settings = {
                binds = {
                  "Mod+S".action.spawn-sh = "noctalia-shell ipc call controlCenter toggle";
                  "XF86AudioRaiseVolume".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "volume"
                    "increase"
                  ];
                  "XF86AudioLowerVolume".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "volume"
                    "decrease"
                  ];
                  "XF86AudioMute".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "volume"
                    "muteOutput"
                  ];
                  "XF86MonBrightnessUp".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "brightness"
                    "increase"
                  ];
                  "XF86MonBrightnessDown".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "brightness"
                    "decrease"
                  ];
                  "Mod+Shift+L".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "lockScreen"
                    "lock"
                  ];
                };
                switch-events.lid-close.action.spawn = [
                  "noctalia-shell"
                  "ipc"
                  "call"
                  "lockScreen"
                  "lock"
                ];
                spawn-at-startup = [
                  {
                    command = [
                      "noctalia-shell"
                    ];
                  }
                ];
              };
            })
          ];
        };
    };
}
