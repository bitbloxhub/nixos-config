{
  lib,
  ...
}:
{
  flake-file.inputs.yazi = {
    url = "github:sxyazi/yazi";
    inputs = {
      flake-utils.follows = "flake-utils";
      nixpkgs.follows = "nixpkgs";
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
          catppuccin.yazi.enable = false;
          home.packages = [
            # For drag and drop
            pkgs.ripdrag
            # Markdown preview
            pkgs.glow
          ];
          programs.yazi = {
            enable = true;
            package = inputs'.yazi.packages.default;
            settings = {
              mgr.show_hidden = true;
              plugin = {
                prepend_fetchers = [
                  {
                    group = "git";
                    id = "git";
                    run = "git";
                    url = "*";
                  }
                  {
                    group = "git";
                    id = "git";
                    run = "git";
                    url = "*/";
                  }
                ];
                prepend_previewers = [
                  {
                    run = "piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark \"$1\"";
                    url = "*.md";
                  }
                ];
              };
            };
            enableNushellIntegration = true;
            initLua = ./init.lua;
            keymap.mgr.prepend_keymap = [
              {
                desc = "Enter the child directory, or open the file";
                on = "<Enter>";
                run = "plugin smart-enter";
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
                desc = "Go back to the root of the git repo";
                on = [
                  "g"
                  "r"
                ];
                run = "shell -- ya emit cd \"$(git rev-parse --show-toplevel)\"";
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
                desc = "Show Git file changes";
                on = [
                  "g"
                  "c"
                ];
                run = "plugin vcs-files";
              }
              # chmod
              {
                desc = "Chmod on selected files";
                on = [
                  "c"
                  "m"
                ];
                run = "plugin chmod";
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
                  desc = "Move in relative steps";
                  on = step;
                  run = "plugin relative-motions" + (if step != "0" then " " + step else "");
                }
              ) (lib.lists.range 0 9));
            plugins = {
              inherit (npins) relative-motions;
              chmod = "${npins.yazi-plugins}/chmod.yazi";
              git = "${npins.yazi-plugins}/git.yazi";
              parent-arrow = ./plugins/parent-arrow.yazi;
              piper = "${npins.yazi-plugins}/piper.yazi";
              smart-enter = "${npins.yazi-plugins}/smart-enter.yazi";
              types = "${npins.yazi-plugins}/types.yazi";
              vcs-files = "${npins.yazi-plugins}/vcs-files.yazi";
            };
            shellWrapperName = "y";
            theme = lib.mkMerge [
              # Restore IFD from https://github.com/catppuccin/nix/commit/8eada392fd6571a747e1c5fc358dd61c14c8704e to change the background color
              (lib.importTOML "${config.catppuccin.sources.yazi}/${config.catppuccin.flavor}/catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}.toml")
              {
                app.overall.bg = lib.mkForce "reset";
                mgr.symlink_target.bg = lib.mkForce "reset";
              }
            ];
          };
        };
    };
}
