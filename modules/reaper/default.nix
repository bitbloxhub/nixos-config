{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    reanix = {
      # Don't overwrite reaper-kb
      url = "github:bitbloxhub/reanix/reaper-kb";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.margesimpson.follows = "margesimpson"; # following flake-parts
      inputs.mrtnvgr.follows = "mrtnvgr";
    };
    # See https://github.com/mrtnvgr/reanix/issues/4
    mrtnvgr = {
      url = "github:mrtnvgr/nurpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
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
                inputs',
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
                  options = {
                    continuous_scrolling = true;

                    # https://github.com/mrtnvgr/reanix/issues/3
                    paths = {
                      renders = "Renders";
                    };
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

                xdg.configFile."REAPER/ColorThemes/Reapertips.ReaperThemeZip".source =
                  inputs'.mrtnvgr.legacyPackages.reapertips-dark.override
                    {
                      undimmed = true;
                      colored_track_names = true;
                    };

                # Reaper MIDI notes colormap
                xdg.configFile."REAPER/Data/color_maps/default.png".source = pkgs.fetchurl {
                  url = "https://i.imgur.com/Ca0JhRF.png";
                  hash = "sha256-FSANQn2V4TjYUvNr4UV1qUhOSeUkT+gsd1pPj4214GY=";
                };

                # TODO: needs more work, possibly upstream to nixpkgs
                # home.packages = [
                #   # Maintained YSFX fork
                #   (pkgs.ysfx.overrideAttrs (old: {
                #     src = pkgs.fetchFromGitHub {
                #       owner = "JoepVanlier";
                #       repo = "ysfx";
                #       rev = "370c91915b0f26f5051705620b0712d06753bd41";
                #       hash = "sha256-9PFBDUOvLCQcZvL8TsG8MVZYzdHsaKK/Pb7S5A1dJBE=";
                #     };
                #
                #     prePatch = old.prePatch + ''
                #       rmdir thirdparty/clap-juce-extensions
                #       ln -s ${
                #         pkgs.fetchFromGitHub {
                #           owner = "free-audio";
                #           repo = "clap-juce-extensions";
                #           rev = "24e70f7f7cde2842528bb66ff50260b1dc0f4dae";
                #           hash = "sha256-ckfEE6g+Za0sdZgKxYuHkA+Z8joZWbriVsjzebKEMA0=";
                #         }
                #       } thirdparty/clap-juce-extensions
                #     '';
                #   }))
                # ];

                home.persistence."/persistent".directories = [ ".config/REAPER" ];
              };
          };
        };
    };
}
