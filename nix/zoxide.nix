{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.zoxide.enable = self.lib.mkDisableOption "zoxide";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.zoxide.enable {
        home.persistence."/persistent".directories = [ ".local/share/zoxide" ];
        programs.zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };
      };
  };
}
