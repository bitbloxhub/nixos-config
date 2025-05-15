{
  inputs,
  ...
}:

{
  nixCats = {
    enable = true;
    nixpkgs_version = inputs.nixpkgs;
    luaPath = ./.;
    packageNames = [ "nvim" ];
    categoryDefinitions.replace = (
      {
        pkgs,
        settings,
        categories,
        name,
        ...
      }@packageDef:
      {
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            pkgs.python3Packages.jupytext
            basedpyright
            ruff
            lua-language-server
            typescript-language-server
            svelte-language-server
            deno
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
          general =
            let
              animotion-nvim = pkgs.vimUtils.buildVimPlugin {
                name = "AniMotion.nvim";
                src = builtins.fetchGit {
                  url = "https://github.com/luiscassih/AniMotion.nvim.git";
                  rev = "a1adf214e276fa8c3f439ce3fa13a6f647744dab";
                };
              };
              # TODO: temporary solution, needed for commit https://github.com/rachartier/tiny-inline-diagnostic.nvim/commit/e563f38
              tiny-inline-diagnostic-nvim = pkgs.vimUtils.buildVimPlugin {
                name = "tiny-inline-diagnostic.nvim";
                src = builtins.fetchGit {
                  url = "https://github.com/rachartier/tiny-inline-diagnostic.nvim.git";
                  rev = "842983e91e0b8825f1084b8323c7806c8bf64c74";
                };
              };
            in
            with pkgs.vimPlugins;
            [
              lze
              lzextras
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
              animotion-nvim
              orgmode
              org-roam-nvim
              codecompanion-nvim
              tiny-inline-diagnostic-nvim
              visual-whitespace-nvim
              treewalker-nvim
              smear-cursor-nvim
            ];
        };
      }
    );
    packageDefinitions.replace = {
      nvim =
        { pkgs, ... }:
        {
          settings = {
            wrapRc = true;
            configDirName = "nvim";
            hosts.python3.enable = true;
            suffix-path = false;
          };
          categories = {
            general = true;
          };
        };
    };
  };
}
