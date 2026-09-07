{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.stasis.enable = self.lib.mkDisableOption "stasis";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      let
        lockCommand = lib.getExe stasisLock;
        stasisLock = pkgs.writeShellApplication {
          name = "stasis-lock";
          runtimeInputs = [
            pkgs.hyprlock
            pkgs.systemd
          ];
          text = ''
            loginctl lock-session
            exec hyprlock --immediate-render --no-fade-in
          '';
        };
      in
      lib.mkIf (user.config.stasis.enable && user.config.niri.enable) {
        home.packages = [ pkgs.stasis ];
        programs.niri.settings.spawn-at-startup = [
          {
            command = [ "stasis" ];
          }
        ];
        xdg.configFile."stasis/stasis.rune" = {
          force = true;
          text = ''
            default:
              enable_loginctl_integration true
              enable_dbus_inhibit true
              prepare_sleep_command "${lockCommand}"
              monitor_media true
              ignore_remote_media true
              suspend_inhibit_media [ ]
              inhibit_apps [ ]
              suspend_inhibit_apps [ ]


              ac:
                lock_screen:
                  timeout 300
                  command "${lockCommand}"
                end

                dpms:
                  timeout 300
                  command "niri msg action power-off-monitors"
                  resume_command "niri msg action power-on-monitors"
                end
              end

              battery:
                lock_screen:
                  timeout 300
                  command "${lockCommand}"
                end

                dpms:
                  timeout 300
                  command "niri msg action power-off-monitors"
                  resume_command "niri msg action power-on-monitors"
                end
              end
            end
          '';
        };
      };
  };
}
