{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.wl-mirror.enable = self.lib.mkDisableOption "wl-mirror";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.wl-mirror.enable {
        home.packages = [ pkgs.wl-mirror ];
      };
  };
}
