{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.wl-kbptr.enable = self.lib.mkDisableOption "wl-kbptr";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.wl-kbptr.enable {
        home.packages = [ pkgs.wl-kbptr ];

        xdg.configFile."wl-kbptr/config".source = ./config;
      };
  };
}
