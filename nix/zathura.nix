{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.zathura.enable = self.lib.mkDisableOption "Zathura";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.zathura.enable {
        programs.zathura = {
          enable = true;
          options = {
            recolor = false;
            selection-clipboard = "clipboard";
          };
        };
      };
  };
}
