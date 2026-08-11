{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.hyprlock.enable = self.lib.mkDisableOption "Hyprlock";
    projectors.user.homeManager =
      user:
      lib.mkIf (user.config.hyprlock.enable && user.config.niri.enable) {
        catppuccin.hyprlock.enable = false;
        programs = {
          hyprlock = {
            enable = true;
            settings = {
              auth = {
                fingerprint.enabled = true;
                pam.module = "login";
              };
              background = [
                {
                  monitor = "";
                  path = "${../wallpapers/niri-pool.png}";
                }
              ];
              input-field = [
                {
                  font_color = "rgb(cdd6f4)";
                  font_family = "Fira Code";
                  halign = "right";
                  inner_color = "rgb(1e1e2e)";
                  monitor = "";
                  outer_color = "rgb(cba6f7)";
                  position = "-32, 32";
                  rounding = 12;
                  size = "320, 56";
                  valign = "bottom";
                }
              ];
              label = [
                {
                  font_family = "Fira Code";
                  font_size = 48;
                  halign = "left";
                  monitor = "";
                  position = "32, 32";
                  text = "$TIME12";
                  valign = "bottom";
                }
              ];
            };
          };
          niri.settings.binds."Mod+Alt+L".action.spawn = "hyprlock";
        };
      };
  };
}
