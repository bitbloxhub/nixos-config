{
  lib,
  ...
}:
{
  flake-file.inputs.yawsf = {
    url = "github:bitbloxhub/yawsf";
    inputs.crate2nix.follows = "crate2nix";
    inputs.fenix.follows = "fenix";
    inputs.flake-file.follows = "flake-file";
    inputs.flake-parts.follows = "flake-parts";
    inputs.flint.follows = "flint";
    inputs.import-tree.follows = "import-tree";
    inputs.make-shell.follows = "make-shell";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    let
      pnpm = pkgs.pnpm_11;
    in
    {
      packages.yawsf-webapp = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "yawsf-webapp";
        version = "0.0.1";
        src = ./.;

        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.nodejs
          pkgs.pnpmConfigHook
          pnpm
        ];

        env = {
          CI = "true";
          pnpm_config_manage_package_manager_versions = "false";
        };

        pnpmDeps = pkgs.fetchPnpmDeps {
          inherit (finalAttrs) pname version src;
          inherit pnpm;
          fetcherVersion = 4;
          hash = "sha256-xcCuDDV6mmUOXLbpR3KXBb5lUC+I57UTyi/1my5xBLg=";
        };

        buildPhase = ''
          runHook preBuild

          pnpm build
          pnpm prune --prod

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p "$out/lib/yawsf-webapp"
          cp -r build node_modules package.json "$out/lib/yawsf-webapp/"

          makeWrapper ${lib.getExe pkgs.nodejs} "$out/bin/yawsf-webapp" \
            --add-flags "$out/lib/yawsf-webapp/build" \
            --prefix PATH : ${lib.makeBinPath [ pkgs.cava ]} \
            --set-default ORIGIN http://127.0.0.1:12551 \
            --set-default PORT 12551 \
            --set-default HOST 127.0.0.1

          runHook postInstall
        '';

        meta.mainProgram = "yawsf-webapp";
      });
    };

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.yawsf ];
      _.yawsf.homeManager =
        {
          config,
          inputs',
          pkgs,
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
        lib.mkMerge [
          {
            home.packages = [
              inputs'.yawsf.packages.default
              self'.packages.yawsf-webapp
              pkgs.cava
              bentoToggle
            ];
          }

          (lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
            programs.niri.settings.spawn-at-startup = [
              {
                command = [
                  (lib.getExe inputs'.yawsf.packages.default)
                  "--webapp-command"
                  (lib.getExe self'.packages.yawsf-webapp)
                ];
              }
            ];

            programs.niri.settings.binds."Mod+Shift+B".action.spawn = [
              (lib.getExe bentoToggle)
            ];
          })
        ];
    };
}
