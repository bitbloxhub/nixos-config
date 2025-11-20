{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.ast-grep
        ];
        shellHook = ''
          # For ast-grep
          nix build --inputs-from . nixpkgs#vimPlugins.nvim-treesitter-parsers.xml --out-link ./tree-sitter-xml
        '';
      };
    };
}
