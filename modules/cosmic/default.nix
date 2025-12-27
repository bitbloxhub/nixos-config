{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "desktops.cosmic";

  flake-file.inputs.cosmic-manager = {
    url = "github:HeitorAugustoLN/cosmic-manager";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };

  options.desktops.cosmic = {
    enable = self.lib.mkDisableOption "COSMIC";
  };

  homeManager.ifEnabled = {
    imports = [
      inputs.cosmic-manager.homeManagerModules.cosmic-manager
    ];

    wayland.desktopManager.cosmic.enable = true;
  };
}
