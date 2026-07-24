{
  lib,
  ...
}:
{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.stasis ];
      _.stasis.homeManager =
        {
          config,
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
        lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
          home.packages = [
            pkgs.stasis
          ];
          programs.niri.settings.spawn-at-startup = [
            {
              command = [
                "stasis"
              ];
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
