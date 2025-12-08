{
  lib,
  inputs,
  ...
}:
{
  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    let
      src = (import ./npins).darkreader-declarative;
      npmDeps = pkgs.importNpmLock.buildNodeModules {
        nodejs = pkgs.nodejs_24;
        npmRoot = src;
        package = builtins.fromJSON (builtins.readFile "${src}/package.json");
      };
      darkreader-declarative = pkgs.stdenv.mkDerivation {
        inherit src;
        name = "darkreader-declarative";
        nativeBuildInputs = [ pkgs.nodejs_24 ];
        buildPhase = ''
          mkdir -p node_modules
          cp -r ${npmDeps}/node_modules/* node_modules/
          npm run build:firefox
        '';
        installPhase = ''
          dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
          mkdir -p $dst
          cp build/release/darkreader-firefox.xpi $dst/addon@darkreader.org.xpi
        '';
      };
    in
    {
      programs.firefox.profiles.nix = {
        extensions.packages = [
          darkreader-declarative
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
            immedateModify = false;
          };
          disabledFor =
            (lib.importJSON
              inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.catppuccin-userstyles-domains
            )
            ++ [
              "github.com"
              "en.wikipedia.org"
            ];
        };
      };
    };
}
