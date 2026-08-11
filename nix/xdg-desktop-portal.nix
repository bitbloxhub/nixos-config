{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.xdg-desktop-portal.enable = self.lib.mkDisableOption "XDG Desktop Portal";
    projectors.user.homeManager =
      user:
      {
        config,
        pkgs,
        ...
      }:
      lib.mkIf (user.config.xdg-desktop-portal.enable && user.config.niri.enable) {
        programs.niri.settings.window-rules = [
          {
            default-column-width.fixed = 1440;
            default-window-height.fixed = 720;
            matches = [
              { app-id = "^wezterm.termfilechooser$"; }
            ];
            open-floating = true;
          }
        ];
        systemd.user.packages = [ pkgs.xdg-desktop-portal ] ++ config.xdg.portal.extraPortals;
        xdg = {
          configFile."xdg-desktop-portal-termfilechooser/config".text =
            # TOML
            ''
              [filechooser]
              cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
              env=TERMFILECHOOSER=1
              env=TERMCMD=wezterm start --always-new-process --class wezterm.termfilechooser --workspace termfilechooser
              default_dir=$HOME
              open_mode=default
              save_mode=default
            '';
          portal = {
            enable = true;
            config.common = {
              default = "gtk";
              "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
              "org.freedesktop.impl.portal.ScreenCast" = "gnome";
              "org.freedesktop.impl.portal.Screenshot" = "gnome";
            };
            extraPortals = [
              pkgs.xdg-desktop-portal-gtk
              pkgs.xdg-desktop-portal
              pkgs.xdg-desktop-portal-gnome # Niri uses this for screensharing
              pkgs.xdg-desktop-portal-termfilechooser
            ];
          };
        };
      };
  };
}
