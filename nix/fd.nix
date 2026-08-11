{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.fd.enable = self.lib.mkDisableOption "fd";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.fd.enable {
        programs.fd.enable = true;
      };
  };
}
