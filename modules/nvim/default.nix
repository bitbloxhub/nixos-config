{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.nvim";

  flake-file.inputs.nixCats.url = "github:BirdeeHub/nixCats-nvim";

  options.programs.nvim = {
    enable = self.lib.mkDisableOption "Neovim";
  };

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.nixCats.homeModule
      ];

      nixCats = {
        enable = true;
        nixpkgs_version = inputs.nixpkgs;
        luaPath = ./.;
        packageNames = [ "nvim" ];
        categoryDefinitions.replace =
          {
            pkgs,
            ...
          }:
          {
            lspsAndRuntimeDeps = {
              general = with pkgs; [
                pkgs.python3Packages.jupytext
                typos-lsp
                basedpyright
                ruff
                lua-language-server
                typescript-language-server
                svelte-language-server
                astro-language-server
                mdx-language-server
                deno
                rust-analyzer
                ts_query_ls
              ];
            };
            python3.libraries = {
              general =
                ps: with ps; [
                  pynvim
                  jupyter-client
                  cairosvg # for image rendering
                  pnglatex # for image rendering
                  plotly # for image rendering
                  pyperclip
                ];
            };
            startupPlugins = {
              general = with pkgs.vimPlugins; [
                lze
                # https://github.com/BirdeeHub/lzextras/issues/94, remove when update
                (lzextras.overrideAttrs {
                  src = pkgs.fetchFromGitHub {
                    owner = "BirdeeHub";
                    repo = "lzextras";
                    rev = "4d5b4760f967ab79dc1b54989ea75f19b91cca64";
                    hash = "sha256-qBfvQn+uLm1BHNtXdKgv63CnS9PntgBWesih7n/h0Yc=";
                  };
                })
                mini-nvim
                catppuccin-nvim
                fidget-nvim
                nvim-lspconfig
                nvim-treesitter.withAllGrammars
                blink-cmp
                direnv-vim
                neo-tree-nvim
                fzf-lua
                render-markdown-nvim
                image-nvim
                snacks-nvim
                edgy-nvim
                flatten-nvim
                molten-nvim
                jupytext-nvim
                otter-nvim
                quarto-nvim
                git-conflict-nvim
                #precognition-nvim # Has issues with fzf-lua.
                hardtime-nvim
                orgmode
                org-roam-nvim
                codecompanion-nvim
                tiny-inline-diagnostic-nvim
                visual-whitespace-nvim
                smear-cursor-nvim
                which-key-nvim
                nvim-bqf
                quicker-nvim
                resession-nvim
              ];
            };
          };
        packageDefinitions.replace = {
          nvim = _: {
            settings = {
              wrapRc = true;
              configDirName = "nvim";
              hosts.python3.enable = true;
              suffix-path = false;
            };
            categories = {
              general = true;
            };
            extra = {
              tree_sitter_orgmode_path = "${pkgs.luajitPackages.tree-sitter-orgmode}";
            };
          };
        };
      };
    };
}
