{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      treefmt = {
        projectRootFile = "flake.lock";

        programs.nixfmt.enable = true;
        programs.deadnix.enable = true;
        programs.statix.enable = true;
        programs.stylua.enable = true;
        programs.prettier.enable = true;
        programs.prettier.settings = builtins.fromJSON (builtins.readFile ./.prettierrc);
        settings.formatter."ast-grep" = {
          command = pkgs.bash;
          options = [
            "-euc"
            ''
              for f in "$@"; do
                ${pkgs.ast-grep}/bin/ast-grep scan -U "$f"
              done
            ''
            "--"
          ];
          includes = [ "modules/astal/**/*.tsx" ];
        };
      };
    };
}
