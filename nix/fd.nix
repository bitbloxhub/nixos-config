{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.fd ];
      _.fd.homeManager = {
        programs.fd.enable = true;
      };
    };
}
