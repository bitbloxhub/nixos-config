{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.nix-wrapper-modules = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.wrappers.nvim =
    {
      wlib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.neovim ];
      settings.config_directory = ./.;
      specs.general = {
        data = with pkgs.vimPlugins; [
          lze
          lzextras
          nui-nvim
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
          otter-nvim
          hardtime-nvim
          orgmode
          org-roam-nvim
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
      extraPackages = with pkgs; [
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
        tree_sitter_orgmode_path = "${pkgs.luajitPackages.tree-sitter-orgmode}";
      };
    };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.nvim = inputs.nix-wrapper-modules.lib.evalPackage [
        { inherit pkgs; }
        self.modules.wrappers.nvim
      ];
    };

  flake.aspects.editors =
    { aspect, ... }:
    {
      includes = [ aspect._.nvim ];
      _.nvim.homeManager =
        {
          self',
          ...
        }:
        {
          home.packages = [
            self'.packages.nvim
          ];

          home.persistence."/persistent".directories = [ ".local/share/nvim" ];
        };
    };
}
