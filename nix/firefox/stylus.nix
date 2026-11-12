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
        # importJSON reads the JSON into the Firefox config but does not keep
        # a reference to this derivation. home.packages gcroots the output,
        # preventing GC from forcing a rebuild of the Rust extractor.
        home.packages = [ self'.packages.catppuccin-userstyles ];
        programs.firefox = {
          policies = {
            "3rdparty".Extensions.${stylusExtensionId} = {
              prefs = {
                patchCsp = true;
                updateInterval = 0;
              };
              styles = lib.importJSON "${self'.packages.catppuccin-userstyles}/styles.json";
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
