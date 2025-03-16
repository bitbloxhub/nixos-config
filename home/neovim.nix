{
  inputs,
  ...
}:
{
  nixCats = {
    enable = true;
    nixpkgs_version = inputs.nixpkgs;
    luaPath = "${../nvim}";
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
          ];
        };
        extraPython3Packages = {
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
            in
            with pkgs.vimPlugins;
            [
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
              precognition-nvim
              hardtime-nvim
              animotion-nvim
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
            withPython3 = true;
          };
          categories = {
            general = true;
          };
        };
    };
  };
}
