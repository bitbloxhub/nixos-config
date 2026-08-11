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
        options.firefox.surfingkeys.enable = self.lib.mkDisableOption "Surfingkeys" // {
          default = config.firefox.enable;
        };
      };
    projectors.user.homeManager =
      user:
      {
        inputs',
        ...
      }:
      let
        # not official but its in my fork
        surfingkeysExtensionId = "surfingkeys@brookhong.github.io";
      in
      lib.mkIf user.config.firefox.surfingkeys.enable {
        programs.firefox = {
          policies = {
            "3rdparty".Extensions.${surfingkeysExtensionId} = {
              showAdvanced = true;
              snippets = builtins.readFile ./surfingkeys.js;
            };
            ExtensionSettings.${surfingkeysExtensionId}.private_browsing = true;
          };
          profiles.nix.extensions.packages = [
            inputs'.firefox-extensions-declarative.packages.surfingkeys-declarative
          ];
        };
      };
  };
}
