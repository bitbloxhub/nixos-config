{
  inputs,
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

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.cosmic ];
      _.cosmic.homeManager = {
        imports = [
          inputs.cosmic-manager.homeManagerModules.cosmic-manager
        ];

        wayland.desktopManager.cosmic.enable = true;
      };
    };
}
