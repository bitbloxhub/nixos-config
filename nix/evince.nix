{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.evince.enable = self.lib.mkDisableOption "Evince";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.evince.enable {
        home.packages = [ pkgs.evince ];
      };
  };
}
