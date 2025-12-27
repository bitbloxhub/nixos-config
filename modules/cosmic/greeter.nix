{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "desktops.cosmic.greeter";

  options.desktops.cosmic.greeter = {
    enable = self.lib.mkDisableOption "COSMIC";
  };

  nixos.ifEnabled = {
    services.displayManager.cosmic-greeter.enable = true;
  };

  homeManager.ifEnabled = {
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
}
