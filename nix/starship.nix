{
  lib,
  ...
}:
{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.starship ];
      _.starship.homeManager.programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          character = {
            disabled = false;
            error_symbol = "[❯](bold fg:red)";
            success_symbol = "[❯](bold fg:green)";
            vimcmd_replace_one_symbol = "[❮](bold fg:lavender)";
            vimcmd_replace_symbol = "[❮](bold fg:lavender)";
            vimcmd_symbol = "[❮](bold fg:green)";
            vimcmd_visual_symbol = "[❮](bold fg:yellow)";
          };
          cmd_duration = {
            disabled = false;
            format = " in $duration ";
            min_time = 0;
            show_milliseconds = true;
            show_notifications = false;
            style = "bg:lavender";
          };
          deno = {
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
            style = "bg:green";
            symbol = "";
          };
          directory = {
            format = "[ $path ]($style)";
            style = "bg:peach fg:crust";
            truncation_length = 3;
            truncation_symbol = "…/";
          };
          direnv = {
            disabled = false;
            format = "[$symbol$loaded/$allowed]($style)";
            style = "fg:crust bg:green";
          };
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
          git_branch = {
            format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
            style = "bg:yellow";
            symbol = "";
          };
          git_status = {
            format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
            style = "bg:yellow";
          };
          hostname = {
            disabled = false;
            format = "[@$hostname]($style)";
            ssh_only = false;
            style = "bg:red fg:crust";
          };
          os = {
            disabled = false;
            style = "bg:red fg:crust";
            symbols = {
              Alpine = " ";
              Amazon = " ";
              Android = " ";
              Arch = "󰣇 ";
              Artix = "󰣇 ";
              CentOS = " ";
              Debian = "󰣚 ";
              Fedora = "󰣛 ";
              Gentoo = "󰣨 ";
              Linux = "󰌽 ";
              Macos = "󰀵 ";
              Manjaro = " ";
              Mint = "󰣭 ";
              NixOS = " ";
              Pop = " ";
              Raspbian = "󰐿 ";
              RedHatEnterprise = "󱄛 ";
              Redhat = "󱄛 ";
              SUSE = " ";
              Ubuntu = "󰕈 ";
              Windows = " ";
            };
          };
          python = {
            detect_extensions = [ ];
            format = "[[ $symbol( $version)(#$virtualenv) ](fg:crust bg:green)]($style)";
            style = "bg:green";
            symbol = "";
          };
          rust = {
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
            style = "bg:green";
            symbol = "";
          };
          time = {
            disabled = false;
            format = "[[  $time ](fg:crust bg:lavender)]($style)";
            style = "bg:lavender";
            time_format = "%R";
          };
          username = {
            format = "[ $user]($style)";
            show_always = true;
            style_root = "bg:red fg:crust";
            style_user = "bg:red fg:crust";
          };
        };
        enableNushellIntegration = true;
      };
    };
}
