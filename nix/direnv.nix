{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.direnv ];
      _.direnv.homeManager = {
        home.persistence."/persistent".directories = [ ".local/share/direnv" ];
        programs.direnv = {
          enable = true;
          config.global = {
            strict_env = true;
            warn_timeout = 0;
          };
          enableNushellIntegration = true;
        };
      };
    };
}
