{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.tmux ];
      _.tmux.homeManager =
        {
          pkgs,
          ...
        }:
        {
          catppuccin.tmux.extraConfig =
            # tmux
            ''
              set -g @catppuccin_window_status_style "rounded"
            '';
          programs.tmux = {
            enable = true;
            mouse = true;
            prefix = "C-a";
            plugins = with pkgs.tmuxPlugins; [
              {
                plugin = sensible;
                # Actually for catppuccin, tmux config ordering is stupid and home-manager is bad at it
                extraConfig =
                  # tmux
                  ''
                    # Statusline
                    set -g status-right-length 100
                    set -g status-left-length 100
                    set -g status-left ""
                    set -g status-right "#{E:@catppuccin_status_application}"
                    set -agF status-right "#{E:@catppuccin_status_cpu}"
                    set -ag status-right "#{E:@catppuccin_status_session}"
                    set -ag status-right "#{E:@catppuccin_status_uptime}"
                    set -agF status-right "#{E:@catppuccin_status_battery}"

                    # Popup transparency
                    set-option -wg popup-style bg=default
                  '';
              }
              cpu
              battery
              tmux-fzf
            ];
          };
        };
    };
}
