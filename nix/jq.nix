{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.jq ];
      _.jq.homeManager = {
        programs.jq.enable = true;
      };
    };
}
