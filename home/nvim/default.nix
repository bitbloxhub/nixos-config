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
              orgmode
              org-roam-nvim
              codecompanion-nvim
              tiny-inline-diagnostic-nvim
              visual-whitespace-nvim
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
