{
  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    let
      violentmonkeyExtensionId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
      src = pkgs.fetchFromGitHub {
        owner = "bitbloxhub";
        repo = "violentmonkey-declarative";
        rev = "ba5a25bc7cb32b5b2a1a6a1be375f3ffb4afea95";
        hash = "sha256-/HS4lMXoY8KXkorQKgpecYC5QSBF6aubpSWzf5cnV7E=";
      };
      yarnDeps = pkgs.fetchYarnDeps {
        inherit src;
        pname = "violentmonkey-yarn-deps";
        hash = "sha256-O3373btwBNl7ASzhAf7pxSBSv8LwTuWe6HIkInBhLY4=";
      };
      violentmonkey-declarative = pkgs.stdenv.mkDerivation {
        inherit src;
        name = "violentmonkey-declarative";
        yarnOfflineCache = yarnDeps;
        env.SHARP_FORCE_GLOBAL_LIBVIPS = 1;
        env.npm_config_nodedir = pkgs.nodejs_24;
        nativeBuildInputs = [
          pkgs.nodejs_24
          pkgs.node-gyp
          pkgs.yarn
          pkgs.yarnConfigHook
          pkgs.zip
          pkgs.vips
          pkgs.pkg-config
          pkgs.python3
        ];
        buildPhase = ''
          pushd node_modules/sharp
          yarn --offline run install
          popd
          yarn run build
          pushd dist/
          zip -r ../violentmonkey.xpi .
          popd
        '';
        installPhase = ''
          dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
          mkdir -p $dst
          cp violentmonkey.xpi $dst/${violentmonkeyExtensionId}.xpi
        '';
      };
    in
    {
      programs.firefox.profiles.nix = {
        extensions.packages = [
          violentmonkey-declarative
        ];
      };
      programs.firefox.policies."3rdparty".Extensions.${violentmonkeyExtensionId} = {
        options.autoUpdate = 0;
        scripts = builtins.map (path: builtins.readFile path) [
          # Disabled do to bugs i can't figure out how to fix
          #./userscripts/font-and-transparency.js
        ];
      };
    };
}
