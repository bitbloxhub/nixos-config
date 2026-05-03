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
    catppuccin-userstyles = {
      url = "github:catppuccin/userstyles";
      flake = false;
    };
    catppuccin-cosmic = {
      url = "github:catppuccin/cosmic-desktop";
      flake = false;
    };
  };

  flake.aspects.rices._.catppuccin =
    {
      flavor ? "mocha",
      accent ? "mauve",
      enableCursors ? true,
      cursorAccent ? "dark",
    }:
    {
      nixos = {
        imports = [
          inputs.catppuccin.nixosModules.catppuccin
        ];

        catppuccin = {
          enable = true;
          inherit flavor accent;
        };
      };

      homeManager =
        {
          config,
          pkgs,
          ...
        }:
        let
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
          imports = [
            inputs.catppuccin.homeModules.catppuccin
          ];

          catppuccin = {
            enable = true;
            inherit flavor accent;
            cursors = {
              enable = enableCursors;
              accent = cursorAccent;
            };
            glamour.enable = true;
          };

          dconf.settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };

          gtk = {
            enable = true;
            theme = {
              package = pkgs.magnetic-catppuccin-gtk.overrideAttrs (old: {
                size = "compact";
                accent = [ accent ];
                tweaks = [ flavor ];
                patches =
                  (old.patches or [ ])
                  ++ (builtins.map (x: ./catppuccin-gtk-theme_patches/${x}) (
                    builtins.attrNames (builtins.readDir ./catppuccin-gtk-theme_patches)
                  ));

              });
              name = "Catppuccin-GTK-Dark";
            };

            iconTheme = {
              package = lib.mkForce pkgs.cosmic-icons;
              name = lib.mkForce "Cosmic";
            };
          };

          programs.vivid = {
            enable = true;
            activeTheme = "catppuccin-mocha";
          };

          programs.nushell.extraConfig = ''
            $env.LS_COLORS = (${pkgs.vivid}/bin/vivid generate ${config.programs.vivid.activeTheme})
          '';

          wayland.desktopManager.cosmic.appearance.theme.dark =
            importRON "${inputs.catppuccin-cosmic}/themes/cosmic-settings/catppuccin-${flavor}-${accent}+round.ron";

          wayland.desktopManager.cosmic.configFile = {
            "com.system76.CosmicTheme.Mode" = {
              version = 1;
              entries.is_dark = true;
            };
          };
        };
    };
}
