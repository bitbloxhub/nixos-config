{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.atuin ];
      _.atuin.homeManager = {
        programs.atuin.enable = true;
        programs.atuin.enableNushellIntegration = true;
        programs.atuin.flags = [ "--disable-up-arrow" ];
      };
    };
}
