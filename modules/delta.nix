{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.delta ];
      _.delta.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.delta
          ];
        };
    };
}
