{
  flake.aspects.gui._.firefox =
    { aspect, ... }:
    {
      includes = [ aspect._.surfingkeys ];
      _.surfingkeys.homeManager =
        {
          inputs',
          ...
        }:
        let
          # not official but its in my fork
          surfingkeysExtensionId = "surfingkeys@brookhong.github.io";
        in
        {
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
