{
  flake-file.inputs.cosmic-manager = {
    url = "github:HeitorAugustoLN/cosmic-manager";
    inputs = {
      flake-parts.follows = "flake-parts";
      home-manager.follows = "home-manager";
      nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.gui._.cosmic =
    { aspect, ... }:
    {
      includes = [ aspect._.greeter ];
      _.greeter = {
        homeManager.wayland.desktopManager.cosmic.stateFile."com.system76.CosmicBackground" = {
          entries.wallpapers = [
            {
              __type = "tuple";
              value = [
                "Virtual-1"
                {
                  __type = "enum";
                  value = [
                    "${../wallpapers/miku-polygons.jpg}"
                  ];
                  variant = "Path";
                }
              ];
            }
          ];
          version = 1;
        };
        nixos.services.displayManager.cosmic-greeter.enable = true;
      };
    };
}
