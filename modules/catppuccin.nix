{
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

  bitbloxhub.theming._.catppuccin = flavor: accent: cursorAccent: {
    nixos = {
      imports = [
        inputs.catppuccin.nixosModules.default
      ];

      catppuccin = {
        enable = true;
        inherit flavor accent;
      };
    };

    homeManager = {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      catppuccin = {
        enable = true;
        inherit flavor accent;
        cursors = {
          enable = true;
          accent = cursorAccent;
        };
        glamour.enable = true;
      };
    };
  };
}
