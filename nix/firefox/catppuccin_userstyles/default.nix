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
      catppuccin-userstyles-extractor = craneLib.buildPackage (
        commonArgs
        // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        }
      );
      commonArgs = {
        src = craneLib.cleanCargoSource ./.;
        strictDeps = true;
      };
      craneLib = inputs.crane.mkLib pkgs;
    in
    {
      packages = {
        inherit catppuccin-userstyles-extractor;
        catppuccin-userstyles = pkgs.stdenv.mkDerivation {
          buildPhase = ''
            catppuccin_userstyles_extractor stylus-declarative mocha mocha mauve $out
          '';
          name = "catppuccin-userstyles";
          nativeBuildInputs = [
            catppuccin-userstyles-extractor
          ];
          src = inputs.catppuccin-userstyles;
        };
        catppuccin-userstyles-domains = pkgs.stdenv.mkDerivation {
          buildPhase = ''
            catppuccin_userstyles_extractor domains ./styles/*/catppuccin.user.less $out
          '';
          name = "catppuccin-userstyles-domains";
          nativeBuildInputs = [
            catppuccin-userstyles-extractor
          ];
          src = inputs.catppuccin-userstyles;
        };
      };
    };
}
