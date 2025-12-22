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

  flake.modules.generic.default = {
    options.my.themes.catppuccin = {
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
  };

  flake.modules.nixos.default =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.catppuccin.nixosModules.catppuccin
      ];

      catppuccin.enable = config.my.themes.catppuccin.enable;
      catppuccin.flavor = config.my.themes.catppuccin.flavor;
      catppuccin.accent = config.my.themes.catppuccin.accent;
    };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      catppuccin = {
        inherit (config.my.themes.catppuccin) enable;
        inherit (config.my.themes.catppuccin) flavor;
        inherit (config.my.themes.catppuccin) accent;
        cursors = {
          inherit (config.my.themes.catppuccin) enable;
          accent = config.my.themes.catppuccin.cursorAccent;
        };
        glamour.enable = true;
      };

      dconf.settings."org/gnome/desktop/interface" = lib.mkIf config.my.themes.catppuccin.enable {
        color-scheme = "prefer-dark";
      };

      gtk = lib.mkIf config.my.themes.catppuccin.enable {
        enable = true;
        theme = {
          package = pkgs.magnetic-catppuccin-gtk;
          name = "Catppuccin-GTK-Dark";
        };
      };

      programs.vivid = lib.mkIf config.my.themes.catppuccin.enable {
        enable = true;
        activeTheme = "catppuccin-mocha";
      };

      programs.nushell.extraConfig = lib.mkIf config.my.themes.catppuccin.enable ''
        $env.LS_COLORS = (${pkgs.vivid}/bin/vivid generate ${config.programs.vivid.activeTheme})
      '';
    };
}
