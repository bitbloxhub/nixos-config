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
                "applications:firefox-nightly"
                "applications:org.wezfurlong.wezterm"
                "applications:com.spotify.Client"
                "core:search-emojis"
                "@sovereign/vicinae-extension-awww-switcher-0:wpgrid"
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
            ];
          };

          programs.niri.settings = {
            binds = {
              "Mod+Return".action.spawn = [
                "vicinae"
                "toggle"
              ];
            };
          };
        };
    };
}
