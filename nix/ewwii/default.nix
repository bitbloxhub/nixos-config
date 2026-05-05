{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    ewwii = {
      url = "github:Ewwii-sh/ewwii/0.7.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    yucky-ewwii = {
      url = "github:Ewwii-sh/yucky-ewwii";
      flake = false;
    };
  };

  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    {
      packages.yucky-ewwii-cdylib = pkgs.rustPlatform.buildRustPackage {
        pname = "yucky-ewwii-cdylib";
        version = inputs.yucky-ewwii.rev or "dirty";
        src = inputs.yucky-ewwii;

        postPatch = ''
          substituteInPlace Cargo.toml \
            --replace 'ewwii_plugin_api = "1.1.0"' 'ewwii_plugin_api = { path = "${inputs.ewwii}/crates/plugin_api" }'
        '';

        cargoHash = "sha256-sLd5/e6XXUEzF2Zmysr9CaflV8ZeZ9/VVbK59SCPtMo=";
        cargoBuildFlags = [ "--lib" ];

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/lib/ewwii/plugins"
          cp "target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}/release/libyucky_ewwii${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}" "$out/lib/ewwii/plugins/libyucky_ewwii${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
          runHook postInstall
        '';
      };
    };

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.ewwii ];
      _.ewwii.homeManager =
        {
          inputs',
          pkgs,
          self',
          ...
        }:
        {
          home.packages = [
            inputs'.ewwii.packages.default
          ];

          xdg.configFile."ewwii" = {
            source = pkgs.symlinkJoin {
              name = "ewwii-config";
              paths = [
                ./.
                "${self'.packages.yucky-ewwii-cdylib}/lib/ewwii"
              ];
            };
            recursive = true;
          };
        };
    };
}
