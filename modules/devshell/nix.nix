{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.nixfmt
          pkgs.deadnix
          pkgs.statix
        ];
      };
    };
}
