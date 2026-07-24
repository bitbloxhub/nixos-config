{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.zoxide ];
      _.zoxide.homeManager = {
        home.persistence."/persistent".directories = [ ".local/share/zoxide" ];
        programs.zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };
      };
    };
}
