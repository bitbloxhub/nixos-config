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
          pkgs.nodejs_25
          pkgs.pnpm_10
          pkgs.prettier
        ];
      };
    };
}
