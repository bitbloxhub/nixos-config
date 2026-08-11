{
  lib,
  self,
  ...
}:
{
  flake-file.inputs.yawsf = {
    url = "github:bitbloxhub/yawsf";
    inputs = {
      flake-file.follows = "flake-file";
      crate2nix.follows = "crate2nix";
      fenix.follows = "fenix";
      flake-parts.follows = "flake-parts";
      flint.follows = "flint";
      import-tree.follows = "import-tree";
      make-shell.follows = "make-shell";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
    };
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    let
      iconLookup = pkgs.stdenv.mkDerivation {
        buildInputs = [ pkgs.gtk4 ];
        buildPhase = ''
          $CC "$src" $(pkg-config --cflags --libs gtk4) -o yawsf-icon-lookup
        '';
        dontUnpack = true;
        installPhase = ''
          install -Dm755 yawsf-icon-lookup "$out/bin/yawsf-icon-lookup"
        '';
        nativeBuildInputs = [ pkgs.pkg-config ];
        pname = "yawsf-icon-lookup";
        src = ./icon-lookup.c;
        version = "0.0.1";
      };
      pnpm = pkgs.pnpm_11;
    in
    {
      packages = {
        yawsf-icon-lookup = iconLookup;
        yawsf-webapp = pkgs.stdenv.mkDerivation (finalAttrs: {
          buildPhase = ''
            runHook preBuild

            pnpm build
            pnpm prune --prod

            runHook postBuild
          '';
          env = {
            CI = "true";
            pnpm_config_manage_package_manager_versions = "false";
          };
          installPhase = ''
            runHook preInstall

            mkdir -p "$out/lib/yawsf-webapp"
            cp -r build node_modules package.json "$out/lib/yawsf-webapp/"

            makeWrapper ${lib.getExe pkgs.nodejs} "$out/bin/yawsf-webapp" \
              --add-flags "$out/lib/yawsf-webapp/build" \
            --prefix PATH : ${
              lib.makeBinPath [
                pkgs.cava
                iconLookup
              ]
            } \
            --set-default ORIGIN http://127.0.0.1:12551 \
            --set-default PORT 12551 \
            --set-default HOST 127.0.0.1

            runHook postInstall
          '';
          meta.mainProgram = "yawsf-webapp";
          nativeBuildInputs = [
            pkgs.makeWrapper
            pkgs.nodejs
            pkgs.pnpmConfigHook
            pnpm
          ];
          pname = "yawsf-webapp";
          pnpmDeps = pkgs.fetchPnpmDeps {
            inherit (finalAttrs) pname version src;
            inherit pnpm;
            fetcherVersion = 4;
            hash = "sha256-xcCuDDV6mmUOXLbpR3KXBb5lUC+I57UTyi/1my5xBLg=";
          };
          src = ./.;
          version = "0.0.1";
        });
      };
    };

  flake.grove = {
    types.user.options.yawsf.enable = self.lib.mkDisableOption "YAWSF";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        inputs',
        self',
        ...
      }:
      let
        bentoToggle = pkgs.writeShellApplication {
          name = "yawsf-bento-toggle";
          runtimeInputs = [ pkgs.curl ];
          text = ''
            curl --fail --silent --show-error --request POST \
              http://127.0.0.1:12551/api/bento \
              --header 'content-type: application/json' \
              --data '{"action":"toggle"}'
          '';
        };
      in
      lib.mkIf user.config.yawsf.enable (
        lib.mkMerge [
          {
            home.packages = [
              inputs'.yawsf.packages.default
              self'.packages.yawsf-webapp
              self'.packages.yawsf-icon-lookup
              pkgs.cava
              bentoToggle
            ];
          }

          (lib.mkIf user.config.niri.enable {
            programs.niri.settings = {
              binds."Mod+Shift+B".action.spawn = [
                (lib.getExe bentoToggle)
              ];
              spawn-at-startup = [
                {
                  command = [
                    (lib.getExe inputs'.yawsf.packages.default)
                    "--webapp-command"
                    (lib.getExe self'.packages.yawsf-webapp)
                  ];
                }
              ];
            };
          })
        ]
      );
  };
}
