{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.ripgrep.enable = self.lib.mkDisableOption "ripgrep";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.ripgrep.enable {
        programs.ripgrep.enable = true;
      };
  };
}
