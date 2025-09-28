{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      craneLib = inputs.crane.mkLib pkgs;
      commonArgs = {
        src = craneLib.cleanCargoSource ./.;
        strictDeps = true;
      };
      catppuccin-userstyles-extractor = craneLib.buildPackage (
        commonArgs
        // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        }
      );
    in
    {
      packages.catppuccin-userstyles-extractor = catppuccin-userstyles-extractor;
      packages.catppuccin-userstyles-domains = pkgs.stdenv.mkDerivation {
        name = "catppuccin-userstyles-domains";
        src = inputs.catppuccin-userstyles;
        nativeBuildInputs = [
          catppuccin-userstyles-extractor
        ];
        buildPhase = ''
          catppuccin_userstyles_extractor domains ./styles/*/catppuccin.user.less $out
        '';
      };
      packages.catppuccin-userstyles = pkgs.stdenv.mkDerivation {
        name = "catppuccin-userstyles";
        src = inputs.catppuccin-userstyles;
        nativeBuildInputs = [
          catppuccin-userstyles-extractor
        ];
        buildPhase = ''
          catppuccin_userstyles_extractor stylus-declarative mocha mocha mauve $out
        '';
      };
    };
}
