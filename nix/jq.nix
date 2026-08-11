{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.jq.enable = self.lib.mkDisableOption "jq";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.jq.enable {
        home.packages = [ pkgs.yq-go ];
        programs.jq.enable = true;
      };
  };
}
