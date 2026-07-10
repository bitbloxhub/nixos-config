{
  lib,
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.niri-unstable-patched =
        inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable.overrideAttrs
          {
            # work around bug in firefox opaque region setting by just disabling all
            # opaque_region requests
            postPatch = ''
              pushd /build/cargo-vendor-dir/smithay-0.7.0
              patch -Np1 < ${./disable_smithay_opaque_regions.patch}
              popd
            '';
            doCheck = false;
          };
    };

  flake-file.inputs = {
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        niri-stable.follows = "";
        xwayland-satellite-stable.follows = "";
      };
    };
    xcompose = {
      url = "github:Udzu/xcompose";
      flake = false;
    };
  };

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.niri ];
      _.niri = {
        nixos =
          {
            self',
            ...
          }:
          {
            imports = [
              inputs.niri-flake.nixosModules.niri
            ];

            niri-flake.cache.enable = false; # I enable this in ./nix.nix.
            programs.niri = {
              enable = true;
              package = self'.packages.niri-unstable-patched;
            };
          };
        systemManager =
          {
            self',
            ...
          }:
          {
            systemd.tmpfiles.rules = [
              "L+ /usr/share/wayland-sessions/niri.desktop - - - - ${self'.packages.niri-unstable-patched}/share/wayland-sessions/niri.desktop"
              "L+ /etc/systemd/user/niri.service - - - - ${self'.packages.niri-unstable-patched}/share/systemd/user/niri.service"
              "L+ /etc/systemd/user/niri-shutdown.target - - - - ${self'.packages.niri-unstable-patched}/share/systemd/user/niri-shutdown.target"
            ];
          };
        homeManager =
          {
            pkgs,
            inputs',
            self',
            ...
          }:
          {
            imports = [
              inputs.niri-flake.homeModules.niri
            ];

            home.packages = [
              pkgs.wl-clipboard
              pkgs.hyprpicker
              pkgs.xcompose
            ];

            xdg.configFile."XCompose".source =
              pkgs.runCommand "XCompose"
                {
                  nativeBuildInputs = [ pkgs.perl ];
                }
                ''
                  while IFS= read -r line; do
                    case "$line" in
                      'include "HangulSyllables"')
                        cat ${inputs.xcompose}/HangulSyllables
                        ;;
                      'include "Logograms"')
                        cat ${inputs.xcompose}/Logograms
                        ;;
                      *)
                        printf '%s\n' "$line"
                        ;;
                    esac
                  done < ${inputs.xcompose}/Compose > "$out"

                  # Compose permits a quoted string plus at most one keysym. The string
                  # already contains every codepoint, so remove invalid multi-keysym suffixes.
                  perl -i -pe \
                    's{(:\s*"(?:\\.|[^"])*")\s+U[0-9A-Fa-f]+(?:\s+U[0-9A-Fa-f]+)+(?=\s*(?:#|$))}{$1}' \
                    "$out"
                '';

            i18n.inputMethod = {
              enable = true;
              type = "fcitx5";

              fcitx5 = {
                settings = {
                  globalOptions = {
                    Behavior = {
                      # false = put preedit in the Fcitx input panel instead of
                      # embedding it inside the application.
                      PreeditEnabledByDefault = false;
                    };

                    "Behavior/DisabledAddons"."0" = "notificationitem";
                    "Behavior/DisabledAddons"."1" = "clipboard";
                  };

                  addons = {
                    keyboard.globalSection = {
                      # Makes Compose sequences expose their partial input as preedit.
                      UseNewComposeBehavior = true;
                    };

                    classicui.globalSection = {
                      Font = "Fira Code 12";
                      MenuFont = "Fira Sans 11";

                      "Vertical Candidate List" = true;
                      WheelForPaging = true;
                      EnableFractionalScale = true;
                      ForceWaylandDPI = 0;
                    };
                  };
                };
              };
            };

            programs.niri = {
              enable = true;
              package = self'.packages.niri-unstable-patched;
              settings = {
                prefer-no-csd = true;
                xwayland-satellite = {
                  enable = true;
                  path = lib.getExe inputs'.niri-flake.packages.xwayland-satellite-unstable;
                };
                screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
                layout = {
                  background-color = "transparent";
                  gaps = 8;
                  default-column-width.proportion = 1.0;
                  focus-ring.enable = false;
                  tab-indicator = {
                    place-within-column = true;
                  };
                  shadow = {
                    enable = true;
                    softness = 5;
                    spread = 0;
                  };
                  preset-column-widths = [
                    { proportion = 1. / 2.; }
                    { proportion = 1.; }
                  ];
                };
                input.keyboard.xkb.options = "compose:ralt";
                input.focus-follows-mouse = {
                  enable = true;
                  max-scroll-amount = "0%";
                };
                # WHY IS UNNATURAL SCROLL EVEN A THING
                input.touchpad = {
                  tap = false;
                  dwt = true;
                  natural-scroll = false;
                };
                layer-rules = [
                  {
                    matches = [
                      {
                        namespace = "^awww-daemon$";
                      }
                    ];
                    place-within-backdrop = true;
                  }
                ];
                window-rules = [
                  {
                    clip-to-geometry = true;
                  }
                  {
                    matches = [ { app-id = "Zoom Workplace"; } ];
                    excludes = [
                      { title = "Zoom Meeting"; }
                      { title = "Meeting"; }
                    ];
                    open-floating = true;
                    open-focused = false;
                  }
                ];
                overview.workspace-shadow.enable = false;
                binds = {
                  "Mod+Shift+Slash".action.show-hotkey-overlay = { };

                  "Mod+T".action.spawn = "wezterm";
                  "Mod+B".action.spawn = [ "firefox-nightly" ];

                  "Mod+P".action.spawn = [
                    "hyprpicker"
                    "-an"
                  ]; # Color Picker

                  "Mod+O".action.toggle-overview = { };
                  "Mod+Q".action.close-window = { };

                  "Mod+Left".action.focus-column-left = { };
                  "Mod+Down".action.focus-window-down = { };
                  "Mod+Up".action.focus-window-up = { };
                  "Mod+Right".action.focus-column-right = { };
                  "Mod+H".action.focus-column-left = { };
                  "Mod+J".action.focus-window-down = { };
                  "Mod+K".action.focus-window-up = { };
                  "Mod+L".action.focus-column-right = { };

                  "Mod+Ctrl+Left".action.move-column-left = { };
                  "Mod+Ctrl+Down".action.move-window-down = { };
                  "Mod+Ctrl+Up".action.move-window-up = { };
                  "Mod+Ctrl+Right".action.move-column-right = { };
                  "Mod+Ctrl+H".action.move-column-left = { };
                  "Mod+Ctrl+J".action.move-window-down = { };
                  "Mod+Ctrl+K".action.move-window-up = { };
                  "Mod+Ctrl+L".action.move-column-right = { };

                  "Mod+Page_Down".action.focus-workspace-down = { };
                  "Mod+Page_Up".action.focus-workspace-up = { };
                  "Mod+U".action.focus-workspace-down = { };
                  "Mod+I".action.focus-workspace-up = { };
                  "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
                  "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
                  "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
                  "Mod+Ctrl+I".action.move-column-to-workspace-up = { };

                  "Mod+Shift+Page_Down".action.move-workspace-down = { };
                  "Mod+Shift+Page_Up".action.move-workspace-up = { };
                  "Mod+Shift+U".action.move-workspace-down = { };
                  "Mod+Shift+I".action.move-workspace-up = { };

                  "Mod+WheelScrollDown" = {
                    cooldown-ms = 150;
                    action.focus-workspace-down = { };
                  };
                  "Mod+WheelScrollUp" = {
                    cooldown-ms = 150;
                    action.focus-workspace-up = { };
                  };
                  "Mod+Ctrl+WheelScrollDown" = {
                    cooldown-ms = 150;
                    action.move-column-to-workspace-down = { };
                  };
                  "Mod+Ctrl+WheelScrollUp" = {
                    cooldown-ms = 150;
                    action.move-column-to-workspace-up = { };
                  };

                  "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
                  "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
                  "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
                  "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };

                  "Mod+BracketLeft".action.consume-or-expel-window-left = { };
                  "Mod+BracketRight".action.consume-or-expel-window-right = { };

                  "Mod+Comma".action.consume-window-into-column = { };
                  "Mod+Period".action.expel-window-from-column = { };

                  "Mod+R".action.switch-preset-column-width = { };
                  "Mod+Shift+R".action.switch-preset-window-height = { };
                  "Mod+Ctrl+R".action.reset-window-height = { };
                  "Mod+F".action.maximize-column = { };
                  "Mod+Shift+F".action.fullscreen-window = { };

                  "Mod+Ctrl+F".action.expand-column-to-available-width = { };

                  "Mod+C".action.center-column = { };

                  "Mod+Ctrl+C".action.center-visible-columns = { };

                  "Mod+Minus".action.set-column-width = "-10%";
                  "Mod+Equal".action.set-column-width = "+10%";

                  "Mod+Shift+Minus".action.set-window-height = "-10%";
                  "Mod+Shift+Equal".action.set-window-height = "+10%";

                  "Mod+V".action.toggle-window-floating = { };
                  "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

                  "Mod+W".action.toggle-column-tabbed-display = { };

                  "Print".action.screenshot = { };
                  "Ctrl+Print".action.screenshot-screen = { };
                  "Alt+Print".action.screenshot-window = { };

                  "Mod+Escape" = {
                    allow-inhibiting = false;
                    action.toggle-keyboard-shortcuts-inhibit = { };
                  };

                  "Mod+Shift+E".action.quit = { };
                  "Ctrl+Alt+Delete".action.quit = { };

                  "Mod+Shift+P".action.power-off-monitors = { };

                  "Mod+Shift+Ctrl+O".action.debug-toggle-opaque-regions = { };
                };
              };
            };
          };
      };
    };
}
