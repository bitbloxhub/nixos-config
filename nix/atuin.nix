{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.atuin ];
      _.atuin.homeManager = {
        home.persistence."/persistent".directories = [ ".local/share/atuin" ];
        programs.atuin = {
          enable = true;
          enableNushellIntegration = true;
          flags = [ "--disable-up-arrow" ];
        };
      };
    };
}
