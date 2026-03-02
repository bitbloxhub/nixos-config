{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.gh ];
      _.gh.homeManager = {
        programs.gh.enable = true;
      };
    };
}
