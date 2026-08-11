{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    catppuccin = {
      url = "github:catppuccin/nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-cosmic = {
      url = "github:catppuccin/cosmic-desktop";
      flake = false;
    };
    catppuccin-userstyles = {
      url = "github:catppuccin/userstyles";
      flake = false;
    };
  };

  flake.grove = {
    types.user.options.catppuccin = {
      accent = lib.mkOption {
        default = "mauve";
        type = lib.types.str;
      };
      cursorAccent = lib.mkOption {
        default = "dark";
        type = lib.types.str;
      };
      enable = lib.mkEnableOption "Catppuccin";
      enableCursors = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
      flavor = lib.mkOption {
        default = "mocha";
        type = lib.types.str;
      };
    };
    projectors.user = {
      homeManager =
        user:
        {
          config,
          pkgs,
          ...
        }:
        let
          inherit (user.config.catppuccin)
            accent
            cursorAccent
            enableCursors
            flavor
            ;
          # TODO: get rid of this hack when https://github.com/NixOS/nixpkgs/pull/440544 is merged
          inherit
            (
              ((import "${inputs.cosmic-manager}/lib/ron.nix") {
                lib = lib // {
                  cosmic = (import "${inputs.cosmic-manager}/lib/modules.nix") { inherit lib; };
                };
              })
            )
            importRON
            ;
        in
        {
          imports = [ inputs.catppuccin.homeModules.catppuccin ];
          catppuccin = {
            inherit flavor accent;
            enable = true;
            autoEnable = true;
            cursors = {
              enable = enableCursors;
              accent = cursorAccent;
            };
            glamour.enable = true;
          };
          dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
          gtk = {
            enable = true;
            gtk4.theme = config.gtk.theme;
            iconTheme = {
              package = lib.mkForce pkgs.cosmic-icons;
              name = lib.mkForce "Cosmic";
            };
            theme = {
              package = pkgs.magnetic-catppuccin-gtk.overrideAttrs (old: {
                accent = [ accent ];
                patches =
                  (old.patches or [ ])
                  ++ (builtins.map (x: ./catppuccin-gtk-theme_patches/${x}) (
                    builtins.attrNames (builtins.readDir ./catppuccin-gtk-theme_patches)
                  ));
                size = "compact";
                tweaks = [ flavor ];

              });
              name = "Catppuccin-GTK-Dark";
            };
          };
          programs = {
            nushell.extraConfig = ''
              $env.LS_COLORS = (${pkgs.vivid}/bin/vivid generate ${config.programs.vivid.activeTheme})
            '';
            vivid = {
              enable = true;
              activeTheme = "catppuccin-mocha";
            };
          };
          wayland.desktopManager.cosmic = {
            appearance.theme.dark = importRON "${inputs.catppuccin-cosmic}/themes/cosmic-settings/catppuccin-${flavor}-${accent}+round.ron";
            configFile."com.system76.CosmicTheme.Mode" = {
              entries.is_dark = true;
              version = 1;
            };
          };
        };
      nixos = user: {
        imports = [
          inputs.catppuccin.nixosModules.catppuccin
        ];
        catppuccin = {
          inherit (user.config.catppuccin) flavor accent;
          enable = true;
        };
      };
    };
  };
}
