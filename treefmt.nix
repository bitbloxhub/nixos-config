{
  perSystem = {
    treefmt = {
      projectRootFile = "flake.lock";

      programs.nixfmt.enable = true;
      programs.deadnix.enable = true;
      programs.statix.enable = true;
      programs.stylua.enable = true;
    };
  };
}
