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
          nix build --inputs-from . nixpkgs#vimPlugins.nvim-treesitter-parsers.xml --out-link ./.tree-sitter-xml
        '';
      };

      treefmt.settings.formatter."ast-grep" = {
        command = pkgs.bash;
        options = [
          "-euc"
          ''
            ln -sfT ${pkgs.vimPlugins.nvim-treesitter-parsers.xml} ./.tree-sitter-xml
            set -o pipefail
            status=0
            for f in "$@"; do
              ${pkgs.ast-grep}/bin/ast-grep scan --color=never -U "$f" >/dev/null
              if ! ${pkgs.ast-grep}/bin/ast-grep scan --report-style=short --color=never "$f" | sed '/^$/d'; then
                status=1
              fi
            done
            exit "$status"
          ''
          "--"
        ];
        # TODO: generate this from ./sg_rules
        includes = [ "**/*.nix" ];
      };
    };
}
