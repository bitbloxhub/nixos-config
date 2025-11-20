{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.stylua
          pkgs.lua-language-server
        ];
      };
    };
}
