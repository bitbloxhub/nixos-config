{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    # following flake-parts
    margesimpson = {
      url = "github:mrtnvgr/margesimpson";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    # See https://github.com/mrtnvgr/reanix/issues/4
    mrtnvgr = {
      url = "github:mrtnvgr/nurpkgs";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    reanix = {
      url = "github:mrtnvgr/reanix";
      inputs = {
        flake-parts.follows = "flake-parts";
        margesimpson.follows = "margesimpson"; # following flake-parts
        mrtnvgr.follows = "mrtnvgr";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  flake.aspects =
    { aspects, ... }:
    {
      daw =
        { aspect, ... }:
        {
          includes = [ aspect._.reaper ];
          _.reaper = {
            includes = [
              (aspects.system._.unfree [
                "reaper"
              ])
            ];
            homeManager =
              {
                config,
                pkgs,
                ...
              }:
              {
                imports = [ inputs.reanix.homeModules.default ];
                # https://github.com/mrtnvgr/reanix/issues/4
                _module.args.inputs = inputs;
                home = {
                  packages = [
                    pkgs.ysfx
                  ];
                  persistence."/persistent".directories = [ ".config/REAPER" ];
                };
                programs = {
                  reanix = {
                    enable = true;
                    config.continuous_scrolling = true;
                    extensions = {
                      js_ReaScriptAPI.enable = true;
                      reaimgui.enable = true;
                      # Trying to do this with Nix is painful, sadly
                      reapack.enable = true;
                      sws.enable = true;
                    };
                    extraConfig = {
                      "reaper-themeconfig.ini" = {
                        # Darken the theme
                        Reapertips.__coloradjust = "1.00000000 -25 -25 51 256 192";
                      };
                      "reaper.ini".reaper = {
                        # Selected themes
                        lastthemefn5 = "${config.xdg.configHome}/REAPER/ColorThemes/Reapertips.ReaperTheme";
                        # PulseAudio
                        linux_audio_mode = 3;
                      };
                    };
                  };
                  reanix.themes.reapertips.enable = true;
                };
                xdg = {
                  configFile = {
                    # Reaper MIDI notes colormap
                    "REAPER/Data/color_maps/default.png".source = pkgs.fetchurl {
                      hash = "sha256-FSANQn2V4TjYUvNr4UV1qUhOSeUkT+gsd1pPj4214GY=";
                      url = "https://i.imgur.com/Ca0JhRF.png";
                    };
                    # Theming
                    "REAPER/libSwell-user.colortheme".source = ./libSwell-user.colortheme;
                  };
                  # FIXME: Does not launch in Vicinae
                  # FIX: Desktop file fixes
                  desktopEntries.reaper.icon = lib.mkForce "${pkgs.reaper}/share/icons/hicolor/256x256/apps/cockos-reaper.png";
                };
              };
          };
        };
    };
}
