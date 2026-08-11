{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.wlr-which-key.enable = self.lib.mkDisableOption "wlr-which-key";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.wlr-which-key.enable {
        home.packages = [ pkgs.wlr-which-key ];
        programs.niri.settings.binds."Mod+Semicolon".action.spawn = [
          "wlr-which-key"
          "mouse"
        ];
        xdg.configFile."wlr-which-key/mouse.yaml".source = ./mouse.yaml;
      };
  };
}
