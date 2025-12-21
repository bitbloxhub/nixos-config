{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.cosmic-manager = {
    url = "github:HeitorAugustoLN/cosmic-manager";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };

  flake.modules.generic.default = {
    options.my.desktops.cosmic = {
      enable = self.lib.mkDisableOption "COSMIC";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
      ];

      wayland.desktopManager.cosmic.enable = config.my.desktops.cosmic.enable;
    };
}
