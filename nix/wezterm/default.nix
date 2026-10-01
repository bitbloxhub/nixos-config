{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.wezterm.enable = self.lib.mkDisableOption "WezTerm";
    projectors.user.homeManager =
      user:
      _:
      lib.mkIf user.config.wezterm.enable {
        catppuccin.wezterm.enable = false;
        home.file."./.config/wezterm/wezterm.lua".source = ./wezterm.lua;
        programs.wezterm.enable = true;
      };
  };
}
