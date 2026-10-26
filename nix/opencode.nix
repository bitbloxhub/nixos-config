{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.opencode.enable = self.lib.mkDisableOption "OpenCode";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.opencode.enable {
        home.packages = [
          pkgs.opencode
          pkgs.opencode-desktop
        ];
        # TODO: declaratively configure
      };
  };
}
