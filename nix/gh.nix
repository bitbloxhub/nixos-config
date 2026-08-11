{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.gh.enable = self.lib.mkDisableOption "GitHub CLI";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.gh.enable {
        programs.gh.enable = true;
      };
  };
}
