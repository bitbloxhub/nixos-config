{
  inputs,
  ...
}:
{
  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      treefmt = {
        projectRootFile = "flake.lock";

        programs.typos.enable = true;
        programs.nixfmt.enable = true;
        programs.deadnix.enable = true;
        programs.statix.enable = true;
        programs.stylua.enable = true;
        programs.prettier.enable = true;
        programs.prettier.settings = builtins.fromJSON (builtins.readFile ./.prettierrc);
        programs.xmllint.enable = true;
        programs.xmllint.package = pkgs.symlinkJoin {
          name = "libxml2-wrapped";
          paths = [ pkgs.libxml2 ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/xmllint \
              --set XMLLINT_INDENT "${"\t"}"
          '';
        };
        programs.rustfmt.enable = true;
        settings.formatter."ast-grep" = {
          command = pkgs.bash;
          options = [
            "-euc"
            ''
              ln -sfT ${pkgs.vimPlugins.nvim-treesitter-parsers.xml} ./.tree-sitter-xml
              for f in "$@"; do
                ${pkgs.ast-grep}/bin/ast-grep scan -U "$f"
              done
            ''
            "--"
          ];
          # TODO: generate this from ./sg_rules
          includes = [
            "modules/astal/**/*.tsx"
            "modules/astal/**/*-symbolic.svg"
          ];
        };

        settings.global.excludes = [
          "*/npins/*"
          "**/pnpm-lock.yaml"
          # Git submodules
          "modules/wezterm/resurrect.wezterm"
          "modules/wezterm/wezterm-types"
        ];
      };
    };
}
