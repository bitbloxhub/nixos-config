{
  flake-file.inputs.cosmic-manager = {
    url = "github:HeitorAugustoLN/cosmic-manager";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };

  flake.aspects.gui._.cosmic =
    { aspect, ... }:
    {
      includes = [ aspect._.greeter ];
      _.greeter = {
        nixos = {
          services.displayManager.cosmic-greeter.enable = true;
        };
        homeManager = {
          wayland.desktopManager.cosmic.stateFile = {
            "com.system76.CosmicBackground" = {
              version = 1;
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
            };
          };
        };
      };
    };
}
