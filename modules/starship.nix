{
  lib,
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.starship = {
      enable = self.lib.mkDisableOption "Starship";
      enableNushellIntegration = self.lib.mkDisableOption "Starship Nushell integration";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.starship.enable = config.my.programs.starship.enable;
      programs.starship.enableNushellIntegration = config.my.programs.starship.enableNushellIntegration;

      programs.starship.settings = {
        add_newline = false;
        format = lib.concatStrings [
          "[](fg:red)"
          "$os"
          "$username"
          "$hostname"
          "[](fg:red)"
          "[─](fg:overlay1)"
          "[](fg:peach)"
          "$directory"
          "[](fg:peach)"
          "[─](fg:overlay1)"
          "[](fg:yellow)"
          "$git_branch"
          "$git_status"
          "[](fg:yellow)"
          "[─](fg:overlay1)"
          "[](fg:green)"
          "$direnv"
          "$rust"
          "$python"
          "$deno"
          "[](fg:green)"
          "[─](fg:overlay1)"
          "[](fg:lavender)"
          "$time"
          "[ ](fg:lavender)"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        os = {
          disabled = false;
          style = "bg:red fg:crust";
          symbols = {
            Windows = " ";
            Ubuntu = "󰕈 ";
            SUSE = " ";
            Raspbian = "󰐿 ";
            Mint = "󰣭 ";
            Macos = "󰀵 ";
            Manjaro = " ";
            Linux = "󰌽 ";
            Gentoo = "󰣨 ";
            Fedora = "󰣛 ";
            Alpine = " ";
            Amazon = " ";
            Android = " ";
            Arch = "󰣇 ";
            Artix = "󰣇 ";
            CentOS = " ";
            Debian = "󰣚 ";
            Redhat = "󱄛 ";
            RedHatEnterprise = "󱄛 ";
            Pop = " ";
            NixOS = " ";
          };
        };

        username = {
          show_always = true;
          style_user = "bg:red fg:crust";
          style_root = "bg:red fg:crust";
          format = "[ $user]($style)";
        };

        hostname = {
          disabled = false;
          ssh_only = false;
          style = "bg:red fg:crust";
          format = "[@$hostname]($style)";
        };

        directory = {
          style = "bg:peach fg:crust";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };

        git_branch = {
          symbol = "";
          style = "bg:yellow";
          format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
        };

        git_status = {
          style = "bg:yellow";
          format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
        };

        direnv = {
          disabled = false;
          style = "fg:crust bg:green";
          format = "[$symbol$loaded/$allowed]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };

        python = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version)(\(#$virtualenv\)) ](fg:crust bg:green)]($style)";
          detect_extensions = [ ];
        };

        deno = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:lavender";
          format = "[[  $time ](fg:crust bg:lavender)]($style)";
        };

        character = {
          disabled = false;
          success_symbol = "[❯](bold fg:green)";
          error_symbol = "[❯](bold fg:red)";
          vimcmd_symbol = "[❮](bold fg:green)";
          vimcmd_replace_one_symbol = "[❮](bold fg:lavender)";
          vimcmd_replace_symbol = "[❮](bold fg:lavender)";
          vimcmd_visual_symbol = "[❮](bold fg:yellow)";
        };

        cmd_duration = {
          show_milliseconds = true;
          format = " in $duration ";
          style = "bg:lavender";
          disabled = false;
          show_notifications = false;
          min_time = 0;
        };
      };

    };
}
