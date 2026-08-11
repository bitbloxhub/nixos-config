{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user =
      {
        config,
        ...
      }:
      {
        options.firefox.stylus.enable = self.lib.mkDisableOption "Stylus" // {
          default = config.firefox.enable;
        };
      };
    projectors.user.homeManager =
      user:
      {
        inputs',
        self',
        ...
      }:
      let
        stylusExtensionId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      in
      lib.mkIf user.config.firefox.stylus.enable {
        programs.firefox = {
          policies = {
            "3rdparty".Extensions.${stylusExtensionId} = {
              prefs = {
                patchCsp = true;
                updateInterval = 0;
              };
              styles = lib.importJSON self'.packages.catppuccin-userstyles;
            };
            ExtensionSettings.${stylusExtensionId}.private_browsing = true;
          };
          profiles.nix.extensions.packages = [
            inputs'.firefox-extensions-declarative.packages.stylus-declarative
          ];
        };
      };
  };
}
