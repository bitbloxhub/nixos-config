{
  flake.aspects.daw =
    { aspect, ... }:
    {
      includes = [ aspect._.surge-xt ];
      _.surge-xt.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [ pkgs.surge-xt ];
        };
    };
}
