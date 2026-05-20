{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    reanix = {
      url = "github:mrtnvgr/reanix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.margesimpson.follows = "margesimpson"; # following flake-parts
      inputs.mrtnvgr.follows = "mrtnvgr";
    };
    # See https://github.com/mrtnvgr/reanix/issues/4
    mrtnvgr = {
      url = "github:mrtnvgr/nurpkgs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    # following flake-parts
    margesimpson = {
      url = "github:mrtnvgr/margesimpson";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
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
                # https://github.com/mrtnvgr/reanix/issues/4
                _module.args.inputs = inputs;
                imports = [ inputs.reanix.homeModules.default ];
                programs.reanix = {
                  enable = true;
                  extensions = {
                    sws.enable = true;
                    reaimgui.enable = true;
                    js_ReaScriptAPI.enable = true;
                    # Trying to do this with Nix is painful, sadly
                    reapack.enable = true;
                  };
                  config = {
                    continuous_scrolling = true;

                    # https://github.com/mrtnvgr/reanix/issues/3
                    paths = {
                      renders = "Renders";
                    };

                    # I have to set these because unalias is broken, https://github.com/mrtnvgr/reanix/issues/5
                    zoom.horizontal = "Edit cursor or play cursor";
                    default_track_height = "medium";
                  };
                  extraConfig = {
                    "reaper.ini" =
                      # dosini
                      ''
                        ; PulseAudio
                        [reaper]
                        linux_audio_mode = 3

                        ; Selected theme
                        [reaper]
                        lastthemefn5=${config.xdg.configHome}/REAPER/ColorThemes/Reapertips.ReaperTheme
                      '';

                    "reaper-themeconfig.ini" =
                      # dosini
                      ''
                        ; Darken the theme
                        [Reapertips]
                        __coloradjust=1.00000000 -25 -25 51 256 192
                      '';
                  };
                };

                # FIXME: Does not launch in Vicinae
                # FIX: Desktop file fixes
                xdg.desktopEntries.reaper = {
                  icon = lib.mkForce "${pkgs.reaper}/share/icons/hicolor/256x256/apps/cockos-reaper.png";
                };

                # Theming
                xdg.configFile."REAPER/libSwell-user.colortheme".source = ./libSwell-user.colortheme;

                programs.reanix.themes.reapertips.enable = true;

                # Reaper MIDI notes colormap
                xdg.configFile."REAPER/Data/color_maps/default.png".source = pkgs.fetchurl {
                  url = "https://i.imgur.com/Ca0JhRF.png";
                  hash = "sha256-FSANQn2V4TjYUvNr4UV1qUhOSeUkT+gsd1pPj4214GY=";
                };

                home.packages = [
                  pkgs.ysfx
                ];

                home.persistence."/persistent".directories = [ ".config/REAPER" ];
              };
          };
        };
    };
}
