{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.ripgrep ];
      _.ripgrep.homeManager = {
        programs.ripgrep.enable = true;
      };
    };
}
