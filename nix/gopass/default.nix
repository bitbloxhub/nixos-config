{
  lib,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.gopass-latest =
        lib.warnIf (lib.versionAtLeast pkgs.gopass.version "1.17.2")
          "gopass is now 1.17.2 or newer; remove the local override"
          pkgs.gopass.overrideAttrs
          (
            finalAttrs: _oldAttrs: {
              src = pkgs.fetchFromGitHub {
                hash = "sha256-BzYy6STOldUZexty8af3RJy6QD7qsTuN7CC8j04V57c=";
                owner = "gopasspw";
                repo = "gopass";
                rev = "v${finalAttrs.version}";
              };
              vendorHash = "sha256-/NW9/lul/ytz8otXqNeJcqbKBBWMJ3wKGrrQciEcXhE=";
              version = "1.17.2";
            }
          );
      treefmt.settings.global.excludes = [
        "nix/gopass/vicinae/assets/extension_icon.svg"
      ];
    };

  flake.grove = {
    types.user.options.gopass.enable = self.lib.mkDisableOption "gopass";
    projectors.user.homeManager =
      user:
      {
        config,
        pkgs,
        self',
        ...
      }:
      let
        gopassVicinae = pkgs.stdenv.mkDerivation rec {
          buildPhase = "pnpm build --out=$out";
          installPhase = "true";
          nativeBuildInputs = [
            pkgs.pnpmConfigHook
            pkgs.pnpm_11
            pkgs.nodejs
          ];
          pname = "gopass-vicinae";
          pnpmDeps = pkgs.fetchPnpmDeps {
            inherit pname src version;
            fetcherVersion = 4;
            hash = "sha256-Wkw2Xgmhq9v1ZBszcsqPqpuND+Hxub1gMX+oTrUehcI=";
            pnpm = pkgs.pnpm_11;
          };
          src = ./vicinae;
          version = "0.1.0";
        };
      in
      lib.mkIf user.config.gopass.enable {
        home = {
          packages = [ self'.packages.gopass-latest ];
          persistence."/persistent".directories = [ ".local/share/gopass" ];
        };
        programs.vicinae.extensions = [ gopassVicinae ];
        xdg.configFile."gopass/config".text = lib.generators.toGitINI {
          age = {
            agent-enabled = false;
            ssh-key-path = "${config.home.homeDirectory}/.ssh/gopass_ed25519.pub";
            sshkeys = true;
          };
          core = {
            cliptimeout = 45;
            notifications = false;
          };
          mounts.path = "${config.home.homeDirectory}/.local/share/gopass/stores/root";
          recipients = {
            check = true;
            hash = "c2776ea80767d9884f1878d3a17b33c70e6206e9aceb348913e4b2ee5c880947";
          };
          show.safecontent = true;
          updater.check = false;
        };
      };
  };
}
