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
          pkgs.nodejs_24
          pkgs.pnpm
          pkgs.prettier
        ];
      };
    };
}
