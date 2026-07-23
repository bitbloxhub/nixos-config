{
  lib,
  ...
}:
{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.hyprlock ];
      _.hyprlock.homeManager =
        {
          config,
          ...
        }:
        lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
          catppuccin.hyprlock.enable = false;

          programs.hyprlock = {
            enable = true;
            settings = {
              auth = {
                pam.module = "login";
              };

              background = [
                {
                  monitor = "";
                  path = "${../wallpapers/niri-pool.png}";
                }
              ];

              label = [
                {
                  monitor = "";
                  text = "$TIME12";
                  font_family = "Fira Code";
                  font_size = 48;

                  position = "32, 32";
                  halign = "left";
                  valign = "bottom";
                }
              ];

              input-field = [
                {
                  monitor = "";

                  size = "320, 56";
                  position = "-32, 32";
                  halign = "right";
                  valign = "bottom";

                  font_family = "Fira Code";

                  outer_color = "rgb(cba6f7)"; # Catppuccin Mocha mauve
                  inner_color = "rgb(1e1e2e)";
                  font_color = "rgb(cdd6f4)";

                  rounding = 12;
                }
              ];
            };
          };

          programs.niri.settings.binds."Mod+Alt+L".action.spawn = "hyprlock";
        };
    };
}
