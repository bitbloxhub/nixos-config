{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.cardinal.enable = self.lib.mkDisableOption "Cardinal";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.cardinal.enable {
        home.packages = [ pkgs.cardinal ];
      };
  };
}
