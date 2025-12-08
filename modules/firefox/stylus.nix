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
      stylusExtensionId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      src = (import ./npins).stylus-declarative;
      pnpmDeps = pkgs.pnpm.fetchDeps {
        inherit src;
        pname = "stylus-pnpm-deps";
        hash = "sha256-9ZPH3FucdwRud6ifJPzGAIjIaVbevJI4ryAHha/v2xc=";
        fetcherVersion = 2; # https://nixos.org/manual/nixpkgs/stable/#javascript-pnpm-fetcherVersion
      };
      stylus-declarative = pkgs.stdenv.mkDerivation {
        inherit src pnpmDeps;
        name = "stylus-declarative";
        nativeBuildInputs = [
          pkgs.nodejs_24
          pkgs.pnpm
          pkgs.pnpm.configHook
        ];
        buildPhase = ''
          pnpm run zip-firefox
        '';
        installPhase = ''
          dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
          mkdir -p $dst
          cp stylus-firefox-*.zip $dst/${stylusExtensionId}.xpi
        '';
      };
    in
    {
      programs.firefox.profiles.nix = {
        extensions.packages = [
          stylus-declarative
        ];
      };
      programs.firefox.policies = {
        ExtensionSettings.${stylusExtensionId}.private_browsing = true;
        "3rdparty".Extensions.${stylusExtensionId} = {
          prefs.patchCsp = true;
          prefs.updateInterval = 0;
          styles =
            lib.importJSON
              inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.catppuccin-userstyles;
        };
      };
    };
}
