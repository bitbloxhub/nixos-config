{
  flake.aspects.daw =
    { aspect, ... }:
    {
      includes = [ aspect._.cardinal ];
      _.cardinal.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [ pkgs.cardinal ];
        };
    };
}
