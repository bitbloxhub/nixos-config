{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.zoxide ];
      _.zoxide.homeManager = {
        programs.zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };
      };
    };
}
