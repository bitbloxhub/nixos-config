{
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.firefox";

  homeManager.ifEnabled =
    {
      inputs',
      ...
    }:
    let
      violentmonkeyExtensionId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
    in
    {
      programs.firefox.profiles.nix = {
        extensions.packages = [
          inputs'.firefox-extensions-declarative.packages.violentmonkey-declarative
        ];
      };
      programs.firefox.policies = {
        ExtensionSettings.${violentmonkeyExtensionId}.private_browsing = true;
        "3rdparty".Extensions.${violentmonkeyExtensionId} = {
          options.autoUpdate = 0;
          scripts = builtins.map (path: builtins.readFile path) [
            # Disabled do to bugs i can't figure out how to fix
            #./userscripts/font-and-transparency.js
          ];
        };
      };
    };
}
