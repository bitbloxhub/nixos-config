{
  lib,
  inputs,
  self,
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

  flake.modules.generic.default = {
    options.my.programs.yazi = {
      enable = self.lib.mkDisableOption "Yazi";
      enableNushellIntegration = self.lib.mkDisableOption "Yazi Nushell integration";
    };
  };

  flake.modules.homeManager.default =
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
      home.packages = lib.mkIf config.my.programs.yazi.enable [
        # For drag and drop
        pkgs.ripdrag
        # Markdown preview
        pkgs.glow
      ];

      programs.yazi = {
        inherit (config.my.programs.yazi) enable;
        inherit (config.my.programs.yazi) enableNushellIntegration;
        package = inputs'.yazi.packages.default;
        plugins = {
          inherit (npins) relative-motions;
          types = "${npins.yazi-plugins}/types.yazi";
          smart-enter = "${npins.yazi-plugins}/smart-enter.yazi";
          git = "${npins.yazi-plugins}/git.yazi";
          vcs-files = "${npins.yazi-plugins}/vcs-files.yazi";
          piper = "${npins.yazi-plugins}/piper.yazi";
          parent-arrow = ./plugins/parent-arrow.yazi;
        };
        initLua = ./init.lua;
        settings = {
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
        theme = {
          flavor = {
            light = "catppuccin";
            dark = "catppuccin";
          };
          which = {
            mask.hidden = true;
          };
          # See https://github.com/sxyazi/yazi/pull/3419 and https://github.com/catppuccin/yazi/pull/29
          indicator = {
            parent = {
              reversed = false;
              fg = "#1e1e2e";
              bg = "#cdd6f4";
            };
            current = {
              fg = "#1e1e2e";
              bg = "#cba6f7";
            };
            preview = {
              fg = "#1e1e2e";
              bg = "#cba6f7";
            };
          };
        };
      };

      # See https://github.com/catppuccin/nix/pull/704#issuecomment-3213454236
      catppuccin.yazi.enable = false;
      # Use the yazi nightly theme from https://github.com/catppuccin/yazi/pull/29
      catppuccin.sources.yazi = pkgs.fetchFromGitHub {
        owner = "xfzv";
        repo = "yazi";
        rev = "699c43d149c216732b6e0b103933ae10c37bcd15";
        hash = "sha256-ScigFyqbAHEGi19TyNNeVyE4iOgWLMpD833XiiRL0Nc=";
      };

      xdg.configFile = {
        "yazi/yazi-plugin".source = lib.mkIf config.my.programs.yazi.enable "${inputs.yazi}/yazi-plugin";

        "yazi/flavors/catppuccin.yazi/flavor.toml".source =
          with config.catppuccin;
          "${sources.yazi}/themes/${flavor}/catppuccin-${flavor}-${accent}.toml";

        "yazi/flavors/catppuccin.yazi/tmtheme.xml".source =
          with config.catppuccin;
          "${sources.bat}/Catppuccin ${lib.toSentenceCase flavor}.tmTheme";
      };
    };
}
