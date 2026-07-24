{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default.packages = [
        pkgs.stylua
        pkgs.lua-language-server
      ];

      treefmt.programs.stylua.enable = true;
    };
}
