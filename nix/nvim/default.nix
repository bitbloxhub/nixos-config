{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tree-sitter-manager-flake = {
      url = "github:bitbloxhub/tree-sitter-manager-flake";
      inputs = {
        flake-file.follows = "flake-file";
        flake-parts.follows = "flake-parts";
        flint.follows = "flint";
        import-tree.follows = "import-tree";
        make-shell.follows = "make-shell";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  perSystem =
    {
      pkgs,
      inputs',
      self',
      ...
    }:
    {
      packages.nvim = inputs.nix-wrapper-modules.lib.evalPackage [
        {
          inherit pkgs;
          _module.args = {
            inherit inputs';
            inherit self';
          };
        }
        self.modules.wrappers.nvim
      ];
    };

  flake = {
    aspects.editors =
      { aspect, ... }:
      {
        includes = [ aspect._.nvim ];
        _.nvim.homeManager =
          {
            self',
            ...
          }:
          {
            home = {
              packages = [
                self'.packages.nvim
              ];
              persistence."/persistent".directories = [ ".local/share/nvim" ];
            };
            programs.git.settings = {
              diff.tool = "codediff";
              difftool.codediff.cmd = ''nvim "$LOCAL" "$REMOTE" +"CodeDiff file $LOCAL $REMOTE"'';
              merge.tool = "codediff";
              mergetool.codediff.cmd = ''nvim "$MERGED" -c "CodeDiff merge \"$MERGED\""'';
            };
          };
      };
    modules.wrappers.nvim =
      {
        pkgs,
        inputs',
        wlib,
        ...
      }:
      {
        imports = [ wlib.wrapperModules.neovim ];
        runtimePkgs = with pkgs; [
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
          gopls
          tinymist
          websocat
        ];
        settings = {
          config_directory = ./.;
          tree_sitter_orgmode_path = "${pkgs.luajitPackages.tree-sitter-orgmode}";
        };
        specs.general.data = with pkgs.vimPlugins; [
          lze
          lzextras
          nui-nvim
          jupyter-api-nvim
          mini-nvim
          catppuccin-nvim
          fidget-nvim
          nvim-lspconfig
          inputs'.tree-sitter-manager-flake.packages.default.withAllGrammars
          blink-cmp
          direnv-vim
          neo-tree-nvim
          neorepl-nvim
          fzf-lua
          render-markdown-nvim
          image-nvim
          otter-nvim
          hardtime-nvim
          orgmode
          org-roam-nvim
          org-notebook-nvim
          codecompanion-nvim
          tiny-inline-diagnostic-nvim
          visual-whitespace-nvim
          which-key-nvim
          nvim-bqf
          quicker-nvim
          qfctl-nvim
          resession-nvim
          noice-nvim
          nvim-spider
          nvim-various-textobjs
          nvim-treesitter-textobjects
          nvim-cokeline
          lualine-nvim
          nvim-lsp-file-operations
          incline-nvim
          nvim-navic
          gitsigns-nvim
          blink-indent
          rainbow-delimiters-nvim
          colorful-winsep-nvim
          codediff-nvim
          yazi-nvim
          typst-preview-nvim
        ];
      };
  };
}
