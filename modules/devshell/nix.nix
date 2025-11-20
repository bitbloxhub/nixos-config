{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.nixfmt-rfc-style
          pkgs.deadnix
          pkgs.statix
        ];
      };
    };
}
