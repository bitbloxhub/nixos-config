{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.atuin.enable = self.lib.mkDisableOption "Atuin";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.atuin.enable {
        home.persistence."/persistent".directories = [ ".local/share/atuin" ];
        programs.atuin = {
          enable = true;
          enableNushellIntegration = true;
          flags = [ "--disable-up-arrow" ];
        };
      };
  };
}
