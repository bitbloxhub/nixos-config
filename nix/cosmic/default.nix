{
  lib,
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.cosmic-manager = {
    url = "github:HeitorAugustoLN/cosmic-manager";
    inputs = {
      flake-parts.follows = "flake-parts";
      home-manager.follows = "home-manager";
      nixpkgs.follows = "nixpkgs";
    };
  };

  flake.grove = {
    types.user.options.cosmic.enable = self.lib.mkDisableOption "Cosmic";
    projectors.user.homeManager =
      user:
      {
        ...
      }:
      {
        imports = [ inputs.cosmic-manager.homeManagerModules.cosmic-manager ];
        config = lib.mkIf user.config.cosmic.enable {
          wayland.desktopManager.cosmic.enable = true;
        };
      };
  };
}
