{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.typos
        ];
      };

      treefmt = {
        programs.typos.enable = true;
      };
    };
}
