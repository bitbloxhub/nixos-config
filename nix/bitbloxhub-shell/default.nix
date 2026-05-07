{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    let
      cargoNix = inputs.crate2nix.tools.${pkgs.stdenv.hostPlatform.system}.generatedCargoNix {
        name = "bitbloxhub-shell";
        src = ./.;
      };

      cargoWorkspace = pkgs.callPackage cargoNix {
        buildRustCrateForPkgs =
          pkgs:
          with pkgs;
          buildRustCrate.override {
            rustc = inputs'.fenix.packages.default.toolchain;
            cargo = inputs'.fenix.packages.default.toolchain;
            defaultCrateOverrides = defaultCrateOverrides // {
              gtk4-layer-shell-sys = attrs: {
                nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ pkg-config ];
                buildInputs = (attrs.buildInputs or [ ]) ++ [ gtk4-layer-shell ];
              };
              bitbloxhub-shell = attrs: {
                postFixup = (attrs.postFixup or "") + ''
                  patchelf --set-rpath "${
                    lib.makeLibraryPath [
                      gtk4
                      glib
                      pango
                      cairo
                      gdk-pixbuf
                      graphene
                      gtk4-layer-shell
                    ]
                  }" $out/bin/bitbloxhub-shell
                '';
              };
            };
          };
      };
    in
    {
      make-shells.default = {
        packages = [
          pkgs.pkg-config

          pkgs.gtk4
          pkgs.glib
          pkgs.pango
          pkgs.cairo
          pkgs.gdk-pixbuf
          pkgs.graphene
          pkgs.gtk4-layer-shell
        ];
      };

      packages.bitbloxhub-shell = cargoWorkspace.rootCrate.build;
    };
}
