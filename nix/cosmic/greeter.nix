{
  lib,
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
    types.user.options.cosmic.greeter.enable = self.lib.mkDisableOption "Cosmic greeter";
    projectors.user = {
      homeManager =
        user:
        lib.mkIf user.config.cosmic.greeter.enable {
          wayland.desktopManager.cosmic.stateFile."com.system76.CosmicBackground" = {
            entries.wallpapers = [
              {
                __type = "tuple";
                value = [
                  "Virtual-1"
                  {
                    __type = "enum";
                    value = [ "${../wallpapers/miku-polygons.jpg}" ];
                    variant = "Path";
                  }
                ];
              }
            ];
            version = 1;
          };
        };
      nixos =
        user:
        lib.mkIf user.config.cosmic.greeter.enable {
          services.displayManager.cosmic-greeter.enable = true;
        };
    };
  };
}
