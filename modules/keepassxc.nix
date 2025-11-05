{
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.keepassxc = {
      enable = self.lib.mkDisableOption "KeePassXC";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.keepassxc = {
        inherit (config.my.programs.keepassxc) enable;
        settings = {
          General.ConfigVersion = 2;
          Browser = {
            Enabled = true;
            UpdateBinaryPath = false;
          };
          Security.IconDownloadFallback = true;
        };
      };
    };
}
