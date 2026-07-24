{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        niri-stable.follows = "";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        xwayland-satellite-stable.follows = "";
      };
    };
    xcompose = {
      url = "github:Udzu/xcompose";
      flake = false;
    };
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.niri-unstable-patched =
        inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable.overrideAttrs
          {
            doCheck = false;
            # work around bug in firefox opaque region setting by just disabling all
            # opaque_region requests
            postPatch = ''
              pushd /build/cargo-vendor-dir/smithay-0.7.0
              patch -Np1 < ${./disable_smithay_opaque_regions.patch}
              popd
            '';
          };
    };

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.niri ];
      _.niri = {
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
            i18n.inputMethod = {
              enable = true;
              fcitx5.settings = {
                addons = {
                  classicui.globalSection = {
                    EnableFractionalScale = true;
                    Font = "Fira Code 12";
                    ForceWaylandDPI = 0;
                    MenuFont = "Fira Sans 11";
                    "Vertical Candidate List" = true;
                    WheelForPaging = true;
                  };
                  keyboard.globalSection = {
                    # Makes Compose sequences expose their partial input as preedit.
                    UseNewComposeBehavior = true;
                  };
                };
                globalOptions = {
                  Behavior = {
                    # false = put preedit in the Fcitx input panel instead of
                    # embedding it inside the application.
                    PreeditEnabledByDefault = false;
                  };
                  "Behavior/DisabledAddons" = {
                    "0" = "notificationitem";
                    "1" = "clipboard";
                  };
                };
              };
              type = "fcitx5";
            };
            programs.niri = {
              enable = true;
              package = self'.packages.niri-unstable-patched;
              settings = {
                binds = {
                  "Alt+Print".action.screenshot-window = { };
                  "Ctrl+Alt+Delete".action.quit = { };
                  "Ctrl+Print".action.screenshot-screen = { };
                  "Mod+B".action.spawn = [ "firefox-nightly" ];
                  "Mod+BracketLeft".action.consume-or-expel-window-left = { };
                  "Mod+BracketRight".action.consume-or-expel-window-right = { };
                  "Mod+C".action.center-column = { };
                  "Mod+Comma".action.consume-window-into-column = { };
                  "Mod+Ctrl+C".action.center-visible-columns = { };
                  "Mod+Ctrl+Down".action.move-window-down = { };
                  "Mod+Ctrl+F".action.expand-column-to-available-width = { };
                  "Mod+Ctrl+H".action.move-column-left = { };
                  "Mod+Ctrl+I".action.move-column-to-workspace-up = { };
                  "Mod+Ctrl+J".action.move-window-down = { };
                  "Mod+Ctrl+K".action.move-window-up = { };
                  "Mod+Ctrl+L".action.move-column-right = { };
                  "Mod+Ctrl+Left".action.move-column-left = { };
                  "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
                  "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
                  "Mod+Ctrl+R".action.reset-window-height = { };
                  "Mod+Ctrl+Right".action.move-column-right = { };
                  "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
                  "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };
                  "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
                  "Mod+Ctrl+Up".action.move-window-up = { };
                  "Mod+Ctrl+WheelScrollDown" = {
                    action.move-column-to-workspace-down = { };
                    cooldown-ms = 150;
                  };
                  "Mod+Ctrl+WheelScrollUp" = {
                    action.move-column-to-workspace-up = { };
                    cooldown-ms = 150;
                  };
                  "Mod+Down".action.focus-window-down = { };
                  "Mod+Equal".action.set-column-width = "+10%";
                  "Mod+Escape" = {
                    action.toggle-keyboard-shortcuts-inhibit = { };
                    allow-inhibiting = false;
                  };
                  "Mod+F".action.maximize-column = { };
                  "Mod+H".action.focus-column-left = { };
                  "Mod+I".action.focus-workspace-up = { };
                  "Mod+J".action.focus-window-down = { };
                  "Mod+K".action.focus-window-up = { };
                  "Mod+L".action.focus-column-right = { };
                  "Mod+Left".action.focus-column-left = { };
                  "Mod+Minus".action.set-column-width = "-10%";
                  "Mod+O".action.toggle-overview = { };
                  "Mod+P".action.spawn = [
                    "hyprpicker"
                    "-an"
                  ]; # Color Picker
                  "Mod+Page_Down".action.focus-workspace-down = { };
                  "Mod+Page_Up".action.focus-workspace-up = { };
                  "Mod+Period".action.expel-window-from-column = { };
                  "Mod+Q".action.close-window = { };
                  "Mod+R".action.switch-preset-column-width = { };
                  "Mod+Right".action.focus-column-right = { };
                  "Mod+Shift+Ctrl+O".action.debug-toggle-opaque-regions = { };
                  "Mod+Shift+E".action.quit = { };
                  "Mod+Shift+Equal".action.set-window-height = "+10%";
                  "Mod+Shift+F".action.fullscreen-window = { };
                  "Mod+Shift+I".action.move-workspace-up = { };
                  "Mod+Shift+Minus".action.set-window-height = "-10%";
                  "Mod+Shift+P".action.power-off-monitors = { };
                  "Mod+Shift+Page_Down".action.move-workspace-down = { };
                  "Mod+Shift+Page_Up".action.move-workspace-up = { };
                  "Mod+Shift+R".action.switch-preset-window-height = { };
                  "Mod+Shift+Slash".action.show-hotkey-overlay = { };
                  "Mod+Shift+U".action.move-workspace-down = { };
                  "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };
                  "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
                  "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
                  "Mod+T".action.spawn = "wezterm";
                  "Mod+U".action.focus-workspace-down = { };
                  "Mod+Up".action.focus-window-up = { };
                  "Mod+V".action.toggle-window-floating = { };
                  "Mod+W".action.toggle-column-tabbed-display = { };
                  "Mod+WheelScrollDown" = {
                    action.focus-workspace-down = { };
                    cooldown-ms = 150;
                  };
                  "Mod+WheelScrollUp" = {
                    action.focus-workspace-up = { };
                    cooldown-ms = 150;
                  };
                  "Print".action.screenshot = { };
                };
                input = {
                  focus-follows-mouse = {
                    enable = true;
                    max-scroll-amount = "0%";
                  };
                  keyboard.xkb.options = "compose:ralt";
                  # WHY IS UNNATURAL SCROLL EVEN A THING
                  touchpad = {
                    dwt = true;
                    natural-scroll = false;
                    tap = false;
                  };
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
                layout = {
                  background-color = "transparent";
                  default-column-width.proportion = 1.0;
                  focus-ring.enable = false;
                  gaps = 8;
                  preset-column-widths = [
                    { proportion = 1. / 2.; }
                    { proportion = 1.; }
                  ];
                  shadow = {
                    enable = true;
                    softness = 5;
                    spread = 0;
                  };
                  tab-indicator.place-within-column = true;
                };
                overview.workspace-shadow.enable = false;
                prefer-no-csd = true;
                screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
                window-rules = [
                  {
                    clip-to-geometry = true;
                  }
                  {
                    excludes = [
                      { title = "Zoom Meeting"; }
                      { title = "Meeting"; }
                    ];
                    matches = [ { app-id = "Zoom Workplace"; } ];
                    open-floating = true;
                    open-focused = false;
                  }
                ];
                xwayland-satellite = {
                  enable = true;
                  path = lib.getExe inputs'.niri-flake.packages.xwayland-satellite-unstable;
                };
              };
            };
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
          };
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
      };
    };
}
