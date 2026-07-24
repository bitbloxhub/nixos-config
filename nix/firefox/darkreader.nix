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
          programs.firefox = {
            policies = {
              "3rdparty".Extensions."addon@darkreader.org" = {
                disabledFor = (lib.importJSON self'.packages.catppuccin-userstyles-domains) ++ [
                  "github.com"
                  "en.wikipedia.org"
                ];
                enableForProtectedPages = true;
                syncSettings = false;
                theme = {
                  brightness = 100;
                  contrast = 100;
                  darkColorScheme = "default";
                  darkSchemeBackgroundColor = "#1e1e2e";
                  darkSchemeTextColor = "#cdd6f4";
                  engine = "dynamicTheme";
                  fontFamily = "Fira Code";
                  grayscale = 0;
                  immediateModify = false;
                  lightColorScheme = "default";
                  lightSchemeBackgroundColor = "#1e1e2e";
                  lightSchemeTextColor = "#cdd6f4";
                  mode = 1;
                  scrollbarColor = "";
                  selectionColor = "#585b70";
                  sepia = 0;
                  styleSystemControls = true;
                  stylesheet = "";
                  textStroke = 0;
                  useFont = false;
                };
              };
              ExtensionSettings."addon@darkreader.org".private_browsing = true;
            };
            profiles.nix.extensions.packages = [
              inputs'.firefox-extensions-declarative.packages.darkreader-declarative
            ];
          };
        };
    };
}
