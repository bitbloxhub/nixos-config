{
  flake.aspects.gui._.firefox =
    { aspect, ... }:
    {
      includes = [ aspect._.violentmonkey ];
      _.violentmonkey.homeManager =
        {
          inputs',
          ...
        }:
        let
          violentmonkeyExtensionId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
        in
        {
          programs.firefox = {
            policies = {
              "3rdparty".Extensions.${violentmonkeyExtensionId} = {
                options.autoUpdate = 0;
                scripts = builtins.map (path: builtins.readFile path) [
                  # Disabled do to bugs i can't figure out how to fix
                  #./userscripts/font-and-transparency.js
                ];
              };
              ExtensionSettings.${violentmonkeyExtensionId}.private_browsing = true;
            };
            profiles.nix.extensions.packages = [
              inputs'.firefox-extensions-declarative.packages.violentmonkey-declarative
            ];
          };
        };
    };
}
