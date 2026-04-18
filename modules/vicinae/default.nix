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
          inputs',
          ...
        }:
        {
          imports = [ inputs.vicinae.homeManagerModules.default ];
          services.vicinae = {
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
                "files".enabled = false;
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
              (inputs'.vicinae.packages.mkRayCastExtension {
                name = "kaomoji-search";
                rev = "870667fc671801a467deb7c4c7fc72992efe3820";
                hash = "sha256-hPpoVU/Bo2dS9A8tp2gDUBAhVqPZ+ZqCn1hyZQ45Wv0=";
              })
            ];
          };

          programs.niri.settings = {
            binds = {
              "Mod+Return".action.spawn = [
                "vicinae"
                "toggle"
              ];
              "Mod+Space".action.spawn = [
                "vicinae"
                "vicinae://extensions/vicinae/wm/switch-windows"
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
        };
    };
}
