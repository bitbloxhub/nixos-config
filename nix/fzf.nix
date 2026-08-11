{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.fzf.enable = self.lib.mkDisableOption "fzf";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.fzf.enable {
        programs.fzf = {
          enable = true;
          colors.bg = lib.mkForce "";
          historyWidget.command = "";
        };
      };
  };
}
