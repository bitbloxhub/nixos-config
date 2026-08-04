{
  inputs,
  ...
}:
{
  flake-file.inputs.reaper-flake = {
    url = "github:9Prestidigitator/reaper-flake";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects = { aspects, ... }: {
    daw = { aspect, ... }: {
      includes = [ aspect._.reaper ];
      _.reaper = {
        includes = [
          (aspects.system._.unfree [
            "reaper"
            "reaper-config-wrapper"
          ])
        ];
        homeManager =
          {
            lib,
            config,
            pkgs,
            inputs',
            ...
          }:
          let
            swsColors = [
              "F5E0E6" # rosewater
              "F2CDCD" # flamingo
              "F5C2E7" # pink
              "CBA6F7" # mauve
              "F38BA8" # red; typos: ignore
              "EBA0AC" # maroon
              "FAB387" # peach
              "F9E2AF" # yellow
              "A6E3A1" # green
              "94E2D5" # teal
              "89DCEB" # sky
              "74C7EC" # sapphire
              "89B4FA" # blue
              "B4BEFE" # lavender
              "CDD6F4" # text
              "BAC2DE" # subtext1
            ];
            swsCustomColors = pkgs.writeText "reaper-sws-custom-colors.lua" ''
              local colors = {
                ${lib.concatMapStringsSep ",\n                " (color: "0x${color}") swsColors}
              }
              local function apply()
                if not reaper.APIExists("CF_SetCustomColor") then
                  reaper.defer(apply)
                  return
                end
                for index, color in ipairs(colors) do
                  reaper.CF_SetCustomColor(index - 1, color)
                end
              end
              apply()
            '';
          in
          {
            imports = [ inputs.reaper-flake.homeModules.reaper ];
            home = {
              packages = [ pkgs.ysfx ];
              persistence."/persistent".directories = [ ".config/REAPER" ];
            };
            programs.reaper = {
              enable = true;
              configPath = "${config.xdg.configHome}/REAPER";
              experimental.swell-wayland.enable = true;
              extensions = {
                reapack = {
                  enable = true;
                  addDefaultRepositories = false;
                  installNewPackagesWhenSynchronizing = false;
                  packages = [
                    {
                      category = "Envelope Palette";
                      name = "BirdBird_Envelope Palette.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "FX Inspector";
                      name = "BirdBird_FX Inspector.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "FX Mangler";
                      name = "BirdBird_FX Mangler.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Functional Console";
                      name = "BirdBird_Functional Console.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Global Sampler";
                      name = "BirdBird_Global Sampler.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Item Modifiers";
                      name = "BirdBird_Item Modifiers.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Note Puncher";
                      name = "BirdBird_Note Puncher.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Parameter History";
                      name = "BirdBird_Parameter History.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Project Tab Sets";
                      name = "BirdBird_Project Tab Sets.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Razor Edit Utility";
                      name = "BirdBird_Razor Edit Utility Settings.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Track Tags";
                      name = "BirdBird_Track Tags.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Track Versions";
                      name = "BirdBird_Track Versions.lua";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "Very Important Compressor";
                      name = "BirdBird_Very Important Compressor.jsfx";
                      repository = "BirdBird ReaScript Testing";
                    }
                    {
                      category = "API";
                      name = "js_ReaScriptAPI.ext";
                      repository = "ReaTeam Extensions";
                    }
                    {
                      category = "API";
                      name = "reaper_imgui.ext";
                      repository = "ReaTeam Extensions";
                    }
                    {
                      category = "Items Editing";
                      name = "cool_MK Slicer.lua";
                      repository = "ReaTeam Scripts";
                    }
                    {
                      category = "Various";
                      name = "pandabot_ChordGun.lua";
                      repository = "ReaTeam Scripts";
                    }
                    {
                      category = "MachineView";
                      name = "MachineView_exec.lua";
                      repository = "Routing tools";
                    }
                    {
                      category = "MachineView";
                      name = "OpenMachineView.lua";
                      repository = "Routing tools";
                    }
                    {
                      category = "Abyss";
                      name = "saike_abyss.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Amaranth";
                      name = "Amaranth.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "BandSplitter.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "MS-20.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Saike Stereo Bub II.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Saike Stereo Bub III.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Saike SuperSpreaderClone.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Saike_Morph.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Saike_Pitch_Shift.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Saike_Routing_Utility.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Tanh_Saturator_AA.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Tight_Compressor.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "ToneStacks.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "Transience.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "saike_never_odd_or_even.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "saike_smooth.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Basics";
                      name = "wahriffic.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "DuskVerb";
                      name = "saike_duskverb.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "FMFilter";
                      name = "FM Filter.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Filther";
                      name = "Filther.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "FinalBoss";
                      name = "saike_final_boss.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Modizer";
                      name = "modizer.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "NOTT"; # typos: ignore
                      name = "nott.jsfx"; # typos: ignore
                      repository = "Saike Tools";
                    }
                    {
                      category = "Nostalgizer";
                      name = "saike_nostalgizer.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Nuker";
                      name = "saike_nuker.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "PhaseMangler";
                      name = "saike_phase_mangler.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Poprocks";
                      name = "poprocks.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Ravager";
                      name = "Ravager_MB.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "ReaBee";
                      name = "ReaBee.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Reflectosaurus";
                      name = "Reflectosaurus.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Ripple";
                      name = "ripple.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "SatanVerb";
                      name = "SatanVerb.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "SequencedFX";
                      name = "SequencedFX.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "SpectrumAnalyzer";
                      name = "LoadSpectrum.lua";
                      repository = "Saike Tools";
                    }
                    {
                      category = "SpectrumAnalyzer";
                      name = "SaikeMultiSpectralAnalyzer.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "SpectrumAnalyzer";
                      name = "SaikeMultiSpectralAnalyzer_MK2.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "SpectrumAnalyzer";
                      name = "StereoSpectrumSplit.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Squashman";
                      name = "Squashman.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Swellotron";
                      name = "Swellotron.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Yutani";
                      name = "Saike_FMFilter2.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Yutani";
                      name = "Saike_Yutani.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "bric-a-brac";
                      name = "saike_bric_a_brac.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "lavaverb";
                      name = "saike_lava.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "partials";
                      name = "saike_partials.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "protosynth";
                      name = "saike_protosynth.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "saike_midi_arp";
                      name = "saike_midi_arp.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "saikedrums";
                      name = "saikedrums.jsfx";
                      repository = "Saike Tools";
                    }
                    {
                      category = "Tracker";
                      name = "tracker.lua";
                      repository = "Tracker tools";
                    }
                  ];
                  repositories = [
                    {
                      installNewPackages = "manual";
                      name = "ReaTeam Scripts";
                      url = "https://raw.githubusercontent.com/ReaTeam/ReaScripts/d1cafa4ff94b1d31ef94c305c984b35c6a922522/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "ReaTeam JSFX";
                      url = "https://raw.githubusercontent.com/ReaTeam/JSFX/442dad421aeec836b87be1489873f9c0d764b26f/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "ReaTeam Themes";
                      url = "https://raw.githubusercontent.com/ReaTeam/Themes/645fb029da2b9db192cf1654e05cd06f8c38b50d/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "ReaTeam LangPacks";
                      url = "https://raw.githubusercontent.com/ReaTeam/LangPacks/2d198804e0ba046464f47c994ab2f2dc436d06f8/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "ReaTeam Extensions";
                      url = "https://raw.githubusercontent.com/ReaTeam/Extensions/1c4257a3d4efa84b867168c6ab20838ec9923f9f/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "MPL Scripts";
                      url = "https://raw.githubusercontent.com/MichaelPilyavskiy/ReaScripts/8a210dbaa326e051ae15ce59239c1ca612a4d6e7/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "X-Raym Scripts";
                      url = "https://raw.githubusercontent.com/X-Raym/REAPER-ReaScripts/af53090308a6fc1bd99bda5347e0c29fe7492ade/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "Saike Tools";
                      url = "https://raw.githubusercontent.com/JoepVanlier/JSFX/241ec8e46320484d87435d2bc0f1388bc520833f/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "BirdBird ReaScript Testing";
                      url = "https://raw.githubusercontent.com/Bird-Bird/ReaScript_Testing/eec561db5605a2d20aec6e8abb190ab12f78785d/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "Routing tools";
                      url = "https://raw.githubusercontent.com/joepvanlier/Hackey-Machines/b30226831843d75e95d32e7ed1077ad0d62cf966/index.xml";
                    }
                    {
                      installNewPackages = "manual";
                      name = "Tracker tools";
                      url = "https://raw.githubusercontent.com/joepvanlier/Hackey-Trackey/5b487ac40401759982563d593f344456c646ad8b/index.xml";
                    }
                  ];
                  synchronizeOnActivation = true;
                };
                sws.enable = true;
              };
              ini = {
                files."reaper-themeconfig.ini"."Reapertips Theme" = {
                  __coloradjust = "1.00000000 -25 -25 51 256 192";
                  param22 = 100;
                };
                sections.reaper = {
                  continuous_scrolling = true;
                  # Use PulseAudio backend; PipeWire's PulseAudio compatibility handles it.
                  linux_audio_mode = 3;
                };
              };
              lineFiles.files."Scripts/__startup.lua" = [
                ''dofile(reaper.GetResourcePath() .. "/Scripts/reaper-nix/sws-custom-colors.lua")''
              ];
              packages = with pkgs; [
                cairo
                fontconfig
                freetype
                glib
                gtk3
                libepoxy
                libpng
                zlib
              ];
              swell.colortheme = {
                enable = true;
                preset = inputs'.reaper-flake.packages.reapertips-theme;
              };
              theme = {
                active = "Reapertips Theme.ReaperThemeZip";
                packages = [ inputs'.reaper-flake.packages.reapertips-theme ];
              };
            };
            xdg.configFile = {
              "REAPER/Data/color_maps/default.png".source = pkgs.fetchurl {
                hash = "sha256-FSANQn2V4TjYUvNr4UV1qUhOSeUkT+gsd1pPj4214GY=";
                url = "https://i.imgur.com/Ca0JhRF.png";
              };
              "REAPER/Scripts/reaper-nix/sws-custom-colors.lua".source = swsCustomColors;
            };
          };
      };
    };
  };
}
