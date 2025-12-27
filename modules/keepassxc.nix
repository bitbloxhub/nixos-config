{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.keepassxc";

  options.programs.keepassxc = {
    enable = self.lib.mkDisableOption "KeePassXC";
  };

  homeManager.ifEnabled = {
    programs.keepassxc = {
      enable = true;
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
