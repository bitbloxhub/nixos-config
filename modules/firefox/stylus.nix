{
  lib,
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.firefox";

  homeManager.ifEnabled =
    {
      inputs',
      self',
      ...
    }:
    let
      stylusExtensionId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
    in
    {
      programs.firefox.profiles.nix = {
        extensions.packages = [
          inputs'.firefox-extensions-declarative.packages.stylus-declarative
        ];
      };
      programs.firefox.policies = {
        ExtensionSettings.${stylusExtensionId}.private_browsing = true;
        "3rdparty".Extensions.${stylusExtensionId} = {
          prefs.patchCsp = true;
          prefs.updateInterval = 0;
          styles = lib.importJSON self'.packages.catppuccin-userstyles;
        };
      };
    };
}
