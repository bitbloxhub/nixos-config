{
  lib,
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
  flake.modules.generic.default = {
    options.my.themes.catppuccin = {
      enable = lib.my.mkDisableOption "Catppuccin";
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
      catppuccin.enable = config.my.themes.catppuccin.enable;
      catppuccin.flavor = config.my.themes.catppuccin.flavor;
      catppuccin.accent = config.my.themes.catppuccin.accent;
    };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      catppuccin.enable = config.my.themes.catppuccin.enable;
      catppuccin.flavor = config.my.themes.catppuccin.flavor;
      catppuccin.accent = config.my.themes.catppuccin.accent;
      catppuccin.cursors.enable = config.my.themes.catppuccin.enable;
      catppuccin.cursors.accent = config.my.themes.catppuccin.cursorAccent;
    };
}
