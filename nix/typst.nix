{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.typst ];
      _.typst.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.typst
            pkgs.typstyle
            pkgs.tinymist
          ];
        };
    };
}
