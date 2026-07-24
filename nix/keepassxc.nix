{
  # Is a GUI app, but the CLI is useful
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.keepassxc ];
      _.keepassxc.homeManager.programs.keepassxc = {
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
}
