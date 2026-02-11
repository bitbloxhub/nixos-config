{
  # Is a GUI app, but the CLI is useful
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.keepassxc ];
      _.keepassxc.homeManager = {
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
    };
}
