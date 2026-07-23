{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.vicinae.follows = "vicinae";
      inputs.flake-compat.follows = "";
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
                systemd = {
                  enable = true;
                  autoStart = true;
                  environment = {
                    USE_LAYER_SHELL = 1;
                  };
                };
                settings = {
                  close_on_focus_loss = true;
                  consider_preedit = true;
                  pop_to_root_on_close = true;
                  favicon_service = "twenty";
                  search_files_in_root = false;
                  telemetry = {
                    system_info = false;
                  };
                  font = {
                    normal = {
                      size = 12;
                      family = "Fira Code";
                    };
                  };
                  theme = {
                    light = {
                      name = "catppuccin-latte";
                      icon_theme = "default";
                    };
                    dark = {
                      name = "catppuccin-mocha";
                      icon_theme = "efault";
                    };
                  };
                  fallbacks = [ ];
                  favorites = [
                    "wm:switch-windows"
                    "@yalishanda/kaomoji-search:index"
                    "core:search-emojis"
                    "@sovereign/vicinae-extension-awww-switcher-0:wpgrid"
                    "applications:firefox-nightly"
                    "applications:org.wezfurlong.wezterm"
                    "applications:com.spotify.Client"
                  ];
                  providers = {
                    "files" = {
                      enabled = false;
                      preferences.autoIndexing = false;
                    };
                    "developer".enabled = false;
                    "clipboard" = {
                      enabled = false;
                      preferences = {
                        monitoring = false;
                      };
                    };
                    "applications".preferences = {
                      defaultAction = "launch";
                    };
                    "@sovereign/vicinae-extension-awww-switcher-0" = {
                      preferences = {
                        wallpaperPath = ../wallpapers;
                      };
                    };
                  };
                };
                extensions = [
                  inputs'.vicinae-extensions.packages.awww-switcher
                  (inputs.vicinae.lib.${pkgs.stdenv.hostPlatform.system}.mkRayCastExtension {
                    name = "kaomoji-search";
                    rev = "f198acd24a916bfe35e6986135ee1ae0ae62eaaf";
                    hash = "sha256-hCkM2qWN5ye/1jbGJAHC4tjpEFlW8FhZOrQB/aK7ltY=";
                  })
                ];
              };
            }

            (lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
              programs.niri.settings = {
                binds = {
                  "Mod+Return".action.spawn = [
                    "vicinae"
                    "toggle"
                  ];
                  "Mod+Space".action.spawn = [
                    "vicinae"
                    "vicinae://launch/wm/switch-windows"
                  ];
                  "Mod+Shift+Space".action.spawn = [
                    "vicinae"
                    "vicinae://launch/@yalishanda/kaomoji-search/index"
                  ];
                  "Mod+Ctrl+Space".action.spawn = [
                    "vicinae"
                    "vicinae://launch/core/search-emojis"
                  ];
                };
              };
            })
          ];
        };
    };
}
