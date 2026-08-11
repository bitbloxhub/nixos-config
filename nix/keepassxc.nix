{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.keepassxc.enable = self.lib.mkDisableOption "KeePassXC";
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.keepassxc.enable {
        programs.keepassxc = {
          enable = true;
          settings = {
            Browser = {
              Enabled = true;
              UpdateBinaryPath = false;
            };
            General.ConfigVersion = 2;
            Security.IconDownloadFallback = true;
          };
        };
      };
  };
}
