{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.direnv ];
      _.direnv.homeManager = {
        programs.direnv = {
          enable = true;
          enableNushellIntegration = true;
          config.global = {
            strict_env = true;
            warn_timeout = 0;
          };
        };
      };
    };
}
