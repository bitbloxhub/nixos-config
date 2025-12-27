{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.swww";

  options.programs.swww = {
    enable = self.lib.mkDisableOption "swww";
  };

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.swww
      ];

      programs.niri.settings = {
        spawn-at-startup = [
          {
            command = [
              "swww-daemon"
            ];
          }
          {
            command = [
              "swww"
              "img"
              "${./wallpapers/miku-v.jpg}"
            ];
          }
        ];
      };
    };
}
