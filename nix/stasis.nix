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
        config,
        pkgs,
        ...
      }:
      let
        lidCloseAction = pkgs.writeShellApplication {
          name = "stasis-lid-close";
          runtimeInputs = [
            lockScreen
            pkgs.systemd
          ];
          text = ''
            # logind is configured to ignore its own lid action. Stasis must
            # lock first, then request suspend itself.
            set -eu
            ready_file="''${XDG_RUNTIME_DIR:-/tmp}/stasis-hyprlock-ready"
            if test -r "$ready_file" && kill -0 "$(cat "$ready_file")" 2>/dev/null; then
              systemctl suspend
              exit 0
            fi
            lock-screen &
            lock_pid=$!
            # Wait for Hyprlock's compositor acknowledgement, not its PID.
            # A running process can exist before ext-session-lock is ready.
            for _ in $(seq 1 100); do
              if test -e "$ready_file"; then
                systemctl suspend
              fi
              if ! kill -0 "$lock_pid" 2>/dev/null; then
                wait "$lock_pid" || true
                exit 1
              fi
              sleep 0.1
            done
            exit 1
          '';
        };
        lidCloseCommand = lib.getExe lidCloseAction;
        lockCommand = lib.getExe lockScreen;
        lockScreen = pkgs.writeShellApplication {
          name = "lock-screen";
          runtimeInputs = [
            pkgs.coreutils
            config.programs.hyprlock.package
            pkgs.ripgrep
            pkgs.util-linux
          ];
          text = ''
            # Hyprlock emits this only after the compositor acknowledges its
            # ext-session-lock-v1 lock. Process existence is not sufficient.
            set -eu
            lock_file="''${XDG_RUNTIME_DIR:-/tmp}/stasis-hyprlock.lock"
            ready_file="''${XDG_RUNTIME_DIR:-/tmp}/stasis-hyprlock-ready"
            exec 9>"$lock_file"
            # One Hyprlock instance owns one compositor lock and one fprintd claim.
            # Reject concurrent launches instead of letting Hyprlock evict itself.
            if ! flock -n 9; then
              exit 0
            fi
            rm -f "$ready_file"
            log_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/stasis"
            log_file="$log_dir/hyprlock.log"
            mkdir -p "$log_dir"
            : > "$log_file"
            trap 'rm -f "$ready_file"' EXIT
            hyprlock --verbose --immediate-render --no-fade-in >"$log_file" 2>&1 &
            lock_pid=$!
            # Keep this handshake local to the lock launcher. Stasis's sleep
            # callback has no lock-readiness signal of its own.
            for _ in $(seq 1 100); do
              # Niri emits this when another lock client owns the session.
              # Stop rejected Hyprlock so Stasis cannot remain falsely locked.
              if rg -q 'onLockFinished called' "$log_file"; then
                kill -TERM "$lock_pid" 2>/dev/null || true
                wait "$lock_pid" || true
                exit 1
              fi
              if rg -q 'onLockLocked called' "$log_file"; then
                printf '%s\n' "$$" > "$ready_file"
                break
              fi
              if ! kill -0 "$lock_pid" 2>/dev/null; then
                wait "$lock_pid" || true
                exit 1
              fi
              sleep 0.1
            done
            wait "$lock_pid"
          '';
        };
        prepareSleepCommand = lockCommand;
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
              prepare_sleep_command "${prepareSleepCommand}"
              lid_close_action "${lidCloseCommand}"
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
