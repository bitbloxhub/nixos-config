{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.ouch.enable = self.lib.mkDisableOption "ouch";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.ouch.enable {
        home.packages = [ pkgs.ouch ];
      };
  };
}
