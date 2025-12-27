{
  lib,
  inputs,
  self,
  ...
}:
let
  niriPkgsForSystem =
    system:
    (lib.makeExtensible (_final: inputs.niri-flake.packages.${system})).extend (
      _final: prev: {
        niri-unstable = prev.niri-unstable.overrideAttrs (
          _final: _prev: {
            patches = [
              #(inputs.nixpkgs.legacyPackages.${system}.fetchpatch {
              #  name = "niri-support-shm.patch";
              #  url = "https://github.com/YaLTeR/niri/compare/1911cf3...wrvsrx:d9cc496.patch";
              #  hash = "sha256-Of+WA05jHnuV8rnz4ZjjQNzI8CcLLT8zoSnUg5n1APU=";
              #})
            ];
            # work around bug in firefox opaque region setting by just disabling all
            # opaque_region requests
            postPatch = ''
              pushd /build/cargo-vendor-dir/smithay-0.7.0
              patch -Np1 < ${./disable_smithay_opaque_regions.patch}
              popd
            '';
            doCheck = false;
          }
        );
      }
    );
in
inputs.not-denix.lib.module {
  name = "programs.niri";

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
  };

  options.programs.niri = {
    enable = self.lib.mkDisableOption "Niri";
  };

  nixos.ifEnabled =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.niri-flake.nixosModules.niri
      ];

      niri-flake.cache.enable = false; # I enable this in ./nix.nix.
      programs.niri = {
        enable = true;
        package = (niriPkgsForSystem config.my.hardware.platform).niri-unstable;
      };
    };

  homeManager.ifEnabled =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.niri-flake.homeModules.niri
      ];

      programs.niri = {
        enable = true;
        package = (niriPkgsForSystem config.my.hardware.platform).niri-unstable;
        settings = {
          prefer-no-csd = true;
          xwayland-satellite = {
            enable = true;
            path = lib.getExe (niriPkgsForSystem config.my.hardware.platform).xwayland-satellite-unstable;
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
                  namespace = "^swww-daemon$";
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

            "XF86AudioRaiseVolume" = {
              allow-when-locked = true;
              action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.05+"
              ];
            };
            "XF86AudioLowerVolume" = {
              allow-when-locked = true;
              action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.05-"
              ];
            };
            "XF86AudioMute" = {
              allow-when-locked = true;
              action.spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
            };
            "XF86AudioMicMute" = {
              allow-when-locked = true;
              action.spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SOURCE@"
                "toggle"
              ];
            };

            "XF86MonBrightnessUp" = {
              allow-when-locked = true;
              action.spawn = [
                "brightnessctl"
                "--class=backlight"
                "set"
                "+5%"
                "--min-value"
                "5%"
              ];
            };
            "XF86MonBrightnessDown" = {
              allow-when-locked = true;
              action.spawn = [
                "brightnessctl"
                "--class=backlight"
                "set"
                "5%-"
                "--min-value"
                "5%"
              ];
            };

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
}
