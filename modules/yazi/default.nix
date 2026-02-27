{
  lib,
  ...
}:
{
  flake-file.inputs = {
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.yazi ];
      _.yazi.homeManager =
        {
          config,
          pkgs,
          inputs',
          ...
        }:
        let
          npins = import ./npins;
        in
        {
          home.packages = [
            # For drag and drop
            pkgs.ripdrag
            # Markdown preview
            pkgs.glow
          ];

          catppuccin.yazi.enable = false;

          programs.yazi = {
            enable = true;
            enableNushellIntegration = true;
            package = inputs'.yazi.packages.default;
            plugins = {
              inherit (npins) relative-motions;
              types = "${npins.yazi-plugins}/types.yazi";
              smart-enter = "${npins.yazi-plugins}/smart-enter.yazi";
              git = "${npins.yazi-plugins}/git.yazi";
              vcs-files = "${npins.yazi-plugins}/vcs-files.yazi";
              piper = "${npins.yazi-plugins}/piper.yazi";
              chmod = "${npins.yazi-plugins}/chmod.yazi";
              parent-arrow = ./plugins/parent-arrow.yazi;
            };
            initLua = ./init.lua;
            theme = lib.mkMerge [
              # Restore IFD from https://github.com/catppuccin/nix/commit/8eada392fd6571a747e1c5fc358dd61c14c8704e to change the background color
              (lib.importTOML "${config.catppuccin.sources.yazi}/${config.catppuccin.flavor}/catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}.toml")
              {
                app.overall.bg = lib.mkForce "reset";
                mgr.symlink_target.bg = lib.mkForce "reset";
              }
            ];
            settings = {
              mgr.show_hidden = true;
              plugin.prepend_fetchers = [
                {
                  id = "git";
                  url = "*";
                  run = "git";
                }
                {
                  id = "git";
                  url = "*/";
                  run = "git";
                }
              ];
              plugin.prepend_previewers = [
                {
                  url = "*.md";
                  run = "piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark \"$1\"";
                }
              ];
            };
            keymap.mgr.prepend_keymap = [
              {
                on = "<Enter>";
                run = "plugin smart-enter";
                desc = "Enter the child directory, or open the file";
              }
              # https://yazi-rs.github.io/docs/tips#selected-files-to-clipboard
              {
                on = "y";
                run = [
                  ''shell -- for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list''
                  "yank"
                ];
              }
              # https://yazi-rs.github.io/docs/tips/#cd-to-git-root
              {
                on = [
                  "g"
                  "r"
                ];
                run = "shell -- ya emit cd \"$(git rev-parse --show-toplevel)\"";
                desc = "Go back to the root of the git repo";
              }
              # https://github.com/sxyazi/yazi/discussions/327
              {
                on = "<C-n>";
                run = "shell -- ripdrag -Axi $@";
              }
              # https://yazi-rs.github.io/docs/tips/#parent-arrow
              {
                on = "K";
                run = "plugin parent-arrow -1";
              }
              {
                on = "J";
                run = "plugin parent-arrow 1";
              }
              # switch zoxide and fzf
              {
                on = "z";
                run = "plugin zoxide";
              }
              {
                on = "Z";
                run = "plugin fzf";
              }
              # vcs-files
              {
                on = [
                  "g"
                  "c"
                ];
                run = "plugin vcs-files";
                desc = "Show Git file changes";
              }
              # chmod
              {
                on = [
                  "c"
                  "m"
                ];
                run = "plugin chmod";
                desc = "Chmod on selected files";
              }
            ]
            ++
              # From https://github.com/uncenter/flake/blob/30b7053/user/programs/yazi.nix#L127-L137
              (map (
                stepInt:
                let
                  step = toString stepInt;
                in
                {
                  on = step;
                  run = "plugin relative-motions" + (if step != "0" then " " + step else "");
                  desc = "Move in relative steps";
                }
              ) (lib.lists.range 0 9));
          };
        };
    };
}
