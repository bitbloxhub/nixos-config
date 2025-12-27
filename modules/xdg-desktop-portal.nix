{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.xdg-desktop-portal";

  options.programs.xdg-desktop-portal = {
    enable = self.lib.mkDisableOption "xdg-desktop-portal";
  };

  homeManager.ifEnabled =
    {
      config,
      pkgs,
      ...
    }:
    {
      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal
          pkgs.xdg-desktop-portal-gnome # Niri uses this for screensharing
          pkgs.xdg-desktop-portal-termfilechooser
        ];
        config = {
          common = {
            default = "gtk";
            "org.freedesktop.impl.portal.ScreenCast" = "gnome";
            "org.freedesktop.impl.portal.Screenshot" = "gnome";
            "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
          };
        };
      };

      xdg.configFile."xdg-desktop-portal-termfilechooser/config".text =
        # TOML
        ''
          [filechooser]
          cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          env=TERMFILECHOOSER=1
          env=TERMCMD=wezterm start --always-new-process --class wezterm.termfilechooser --workspace termfilechooser
          default_dir=$HOME
          open_mode=suggested
          save_mode=last
        '';

      programs.niri.settings.window-rules = [
        {
          matches = [
            { app-id = "^wezterm.termfilechooser$"; }
          ];
          open-floating = true;
          default-column-width = {
            fixed = 1440;
          };
          default-window-height = {
            fixed = 720;
          };
        }
      ];

      # See ./hm-systemd-packages.nix for more info
      systemd.packages = [ pkgs.xdg-desktop-portal ] ++ config.xdg.portal.extraPortals;
    };
}
