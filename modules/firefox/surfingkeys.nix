{
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.firefox";

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    let
      # not official but its in my fork
      surfingkeysExtensionId = "surfingkeys@brookhong.github.io";
      src = (import ./npins).Surfingkeys-declarative;
      npmDeps = pkgs.importNpmLock.buildNodeModules {
        nodejs = pkgs.nodejs_24;
        npmRoot = src;
        package = builtins.fromJSON (builtins.readFile "${src}/package.json");
        derivationArgs.nativeBuildInputs = [
          pkgs.node-gyp
          pkgs.pkg-config
          pkgs.pixman
          pkgs.cairo
          pkgs.pango
        ];
        derivationArgs.PUPPETEER_SKIP_DOWNLOAD = "1";
      };
      surfingkeys-declarative = pkgs.stdenv.mkDerivation {
        inherit src;
        name = "surfingkeys-declarative";
        nativeBuildInputs = [
          pkgs.nodejs_24
          pkgs.webpack-cli
        ];
        buildPhase = ''
          mkdir -p node_modules
          cp -r ${npmDeps}/node_modules/* node_modules/
          export PATH=./node_modules/.bin/:$PATH
          ls -la ./node_modules/
          browser=firefox npm run build:prod
        '';
        installPhase = ''
          dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
          mkdir -p $dst
          cp dist/production/firefox/sk.zip $dst/${surfingkeysExtensionId}.xpi
        '';
      };
    in
    {
      programs.firefox.profiles.nix = {
        extensions.packages = [
          surfingkeys-declarative
        ];
      };
      programs.firefox.policies = {
        ExtensionSettings.${surfingkeysExtensionId}.private_browsing = true;
        "3rdparty".Extensions.${surfingkeysExtensionId} = {
          showAdvanced = true;
          snippets = builtins.readFile ./surfingkeys.js;
        };
      };
    };
}
