{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.typescript-language-server
          pkgs.nodejs_latest
          pkgs.pnpm_10
          pkgs.prettier
        ];
      };

      treefmt = {
        programs.prettier.enable = true;
        programs.prettier.settings = builtins.fromJSON (builtins.readFile ../.prettierrc);
      };
    };
}
