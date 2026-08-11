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
        xdg.configFile."stasis/stasis.rune".text = ''
          default:
            enable_loginctl true
            enable_dbus_inhibit true

            prepare_sleep_command "${lockCommand}"

            ac:
              lock_screen:
                timeout 300
                command "${lockCommand}"
              end

              dpms:
                timeout 30
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
                timeout 30
                command "niri msg action power-off-monitors"
                resume_command "niri msg action power-on-monitors"
              end
            end
          end
        '';
      };
  };
}
