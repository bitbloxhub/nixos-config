{
  flake.modules.homeManager.default = {
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
