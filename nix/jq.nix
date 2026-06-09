{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.jq ];
      _.jq.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [ pkgs.yq-go ];
          programs.jq.enable = true;
        };
    };
}
