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
        options.firefox.darkreader.enable = self.lib.mkDisableOption "Dark Reader" // {
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
      lib.mkIf user.config.firefox.darkreader.enable {
        # importJSON reads the JSON into the Firefox config but does not keep
        # a reference to this derivation. home.packages gcroots the output,
        # preventing GC from forcing a rebuild of the Rust extractor.
        home.packages = [ self'.packages.catppuccin-userstyles-domains ];
        programs.firefox = {
          policies = {
            "3rdparty".Extensions."addon@darkreader.org" = {
              disabledFor = (lib.importJSON "${self'.packages.catppuccin-userstyles-domains}/domains.json") ++ [
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
