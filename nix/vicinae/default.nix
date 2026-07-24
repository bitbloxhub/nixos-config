{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        vicinae.follows = "vicinae";
      };
    };
  };

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.vicinae ];
      _.vicinae.homeManager =
        {
          lib,
          config,
          pkgs,
          inputs',
          ...
        }:
        {
          imports = [ inputs.vicinae.homeManagerModules.default ];
          config = lib.mkMerge [
            {
              catppuccin.vicinae.enable = false;

              programs.vicinae = {
                enable = true;
                settings = {
                  close_on_focus_loss = true;
                  consider_preedit = true;
                  fallbacks = [ ];
                  favicon_service = "twenty";
                  favorites = [
                    "wm:switch-windows"
                    "@yalishanda/kaomoji-search:index"
                    "core:search-emojis"
                    "@sovereign/vicinae-extension-awww-switcher-0:wpgrid"
                    "applications:firefox-nightly"
                    "applications:org.wezfurlong.wezterm"
                    "applications:com.spotify.Client"
                  ];
                  font.normal = {
                    family = "Fira Code";
                    size = 12;
                  };
                  pop_to_root_on_close = true;
                  providers = {
                    "@sovereign/vicinae-extension-awww-switcher-0".preferences.wallpaperPath = ../wallpapers;
                    "applications".preferences.defaultAction = "launch";
                    "clipboard" = {
                      enabled = false;
                      preferences.monitoring = false;
                    };
                    "developer".enabled = false;
                    "files" = {
                      enabled = false;
                      preferences.autoIndexing = false;
                    };
                  };
                  search_files_in_root = false;
                  telemetry.system_info = false;
                  theme = {
                    dark = {
                      icon_theme = "efault";
                      name = "catppuccin-mocha";
                    };
                    light = {
                      icon_theme = "default";
                      name = "catppuccin-latte";
                    };
                  };
                };
                extensions = [
                  inputs'.vicinae-extensions.packages.awww-switcher
                  (inputs.vicinae.lib.${pkgs.stdenv.hostPlatform.system}.mkRayCastExtension {
                    hash = "sha256-hCkM2qWN5ye/1jbGJAHC4tjpEFlW8FhZOrQB/aK7ltY=";
                    name = "kaomoji-search";
                    rev = "f198acd24a916bfe35e6986135ee1ae0ae62eaaf";
                  })
                ];
                systemd = {
                  enable = true;
                  autoStart = true;
                  environment.USE_LAYER_SHELL = 1;
                };
              };
            }

            (lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
              programs.niri.settings.binds = {
                "Mod+Ctrl+Space".action.spawn = [
                  "vicinae"
                  "vicinae://launch/core/search-emojis"
                ];
                "Mod+Return".action.spawn = [
                  "vicinae"
                  "toggle"
                ];
                "Mod+Shift+Space".action.spawn = [
                  "vicinae"
                  "vicinae://launch/@yalishanda/kaomoji-search/index"
                ];
                "Mod+Space".action.spawn = [
                  "vicinae"
                  "vicinae://launch/wm/switch-windows"
                ];
              };
            })
          ];
        };
    };
}
