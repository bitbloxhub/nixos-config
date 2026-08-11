{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.bat.enable = self.lib.mkDisableOption "bat";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.bat.enable {
        programs.bat.enable = true;
      };
  };
}
