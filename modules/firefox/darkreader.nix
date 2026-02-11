{
  lib,
  ...
}:
{
  flake.aspects.gui._.firefox =
    { aspect, ... }:
    {
      includes = [ aspect._.darkreader ];
      _.darkreader.homeManager =
        {
          inputs',
          self',
          ...
        }:
        {
          programs.firefox.profiles.nix = {
            extensions.packages = [
              inputs'.firefox-extensions-declarative.packages.darkreader-declarative
            ];
          };
          programs.firefox.policies = {
            ExtensionSettings."addon@darkreader.org".private_browsing = true;
            "3rdparty".Extensions."addon@darkreader.org" = {
              syncSettings = false;
              enableForProtectedPages = true;
              theme = {
                mode = 1;
                brightness = 100;
                contrast = 100;
                grayscale = 0;
                sepia = 0;
                useFont = false;
                fontFamily = "Fira Code";
                textStroke = 0;
                engine = "dynamicTheme";
                stylesheet = "";
                darkSchemeBackgroundColor = "#1e1e2e";
                darkSchemeTextColor = "#cdd6f4";
                lightSchemeBackgroundColor = "#1e1e2e";
                lightSchemeTextColor = "#cdd6f4";
                scrollbarColor = "";
                selectionColor = "#585b70";
                styleSystemControls = true;
                darkColorScheme = "default";
                lightColorScheme = "default";
                immediateModify = false;
              };
              disabledFor = (lib.importJSON self'.packages.catppuccin-userstyles-domains) ++ [
                "github.com"
                "en.wikipedia.org"
              ];
            };
          };
        };
    };
}
