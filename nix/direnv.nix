{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.direnv.enable = self.lib.mkDisableOption "direnv";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.direnv.enable {
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
