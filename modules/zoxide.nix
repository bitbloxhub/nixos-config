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
        home.persistence."/persistent".directories = [ ".local/share/zoxide" ];
      };
    };
}
