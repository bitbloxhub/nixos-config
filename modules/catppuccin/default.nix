{
  lib,
  inputs,
  self,
  ...
}:
let
  catppuccinAccent = lib.types.enum [
    "blue"
    "flamingo"
    "green"
    "lavender"
    "maroon"
    "mauve"
    "peach"
    "pink"
    "red"
    "rosewater"
    "sapphire"
    "sky"
    "teal"
    "yellow"
  ];
in
inputs.not-denix.lib.module {
  name = "themes.catppuccin";

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

  options.themes.catppuccin = {
    enable = self.lib.mkDisableOption "Catppuccin";
    flavor = lib.mkOption {
      type = lib.types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "mocha";
      description = "Global Catppuccin flavor";
    };
    accent = lib.mkOption {
      type = catppuccinAccent;
      default = "mauve";
      description = "Global Catppuccin accent";
    };
    cursorAccent = lib.mkOption {
      type = lib.types.mergeTypes catppuccinAccent (
        lib.types.enum [
          "dark"
          "light"
        ]
      );
      default = "dark";
      description = "Catppuccin accent for pointer cursors";
    };
  };

  nixos.ifEnabled =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.catppuccin.nixosModules.catppuccin
      ];

      catppuccin = {
        enable = true;
        inherit (config.my.themes.catppuccin) flavor;
        inherit (config.my.themes.catppuccin) accent;
      };
    };

  homeManager.ifEnabled =
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
        inherit (config.my.themes.catppuccin) flavor;
        inherit (config.my.themes.catppuccin) accent;
        cursors = {
          enable = true;
          accent = config.my.themes.catppuccin.cursorAccent;
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
            accent = [ config.my.themes.catppuccin.accent ];
            tweaks = [ config.my.themes.catppuccin.flavor ];
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
        importRON "${inputs.catppuccin-cosmic}/themes/cosmic-settings/catppuccin-${config.my.themes.catppuccin.flavor}-${config.my.themes.catppuccin.accent}+round.ron";

      wayland.desktopManager.cosmic.configFile = {
        "com.system76.CosmicTheme.Mode" = {
          version = 1;
          entries.is_dark = true;
        };
      };
    };
}
