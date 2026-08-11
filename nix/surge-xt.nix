{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.surge-xt.enable = self.lib.mkDisableOption "Surge XT";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.surge-xt.enable {
        home.packages = [ pkgs.surge-xt ];
      };
  };
}
