{
  lib,
  inputs,
  ...
}:
let
  angrrConfig = {
    profile-policies = {
      system = {
        keep-booted-system = true;
        keep-current-system = true;
        keep-latest-n = 1;
        profile-paths = [
          "/nix/var/nix/profiles/system"
        ];
      };
      system-manager = {
        keep-latest-n = 1;
        profile-paths = [
          "/nix/var/nix/profiles/system-manager-profiles/system-manager"
        ];
      };
      user = {
        keep-latest-n = 1;
        profile-paths = [
          "~/.local/state/nix/profiles/profile"
          "/nix/var/nix/profiles/per-user/root/profile"
        ];
      };
    };
    temporary-root-policies = {
      direnv = {
        path-regex = "/\\.direnv/";
        period = "14d";
      };
      result = {
        path-regex = "/result[^/]*$";
        period = "3d";
      };
    };
  };
in
{
  flake-file.inputs.angrr = {
    url = "github:linyinfeng/angrr";
    inputs = {
      flake-compat.follows = "";
      flake-parts.follows = "flake-parts";
      nix-darwin.follows = "";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
    };
  };

  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.angrr ];
      _.angrr = {
        nixos = {
          imports = [
            inputs.angrr.nixosModules.angrr
          ];

          services.angrr = {
            enable = true;
            settings = angrrConfig;
            timer = {
              enable = true;
              dates = "*-*-* *:00:00";
            };
          };
        };
        systemManager =
          {
            pkgs,
            inputs',
            ...
          }:
          {
            environment = {
              etc."angrr/config.toml".source = (pkgs.formats.toml { }).generate "angrr/config.toml" angrrConfig;
              systemPackages = [ inputs'.angrr.packages.default ];
            };
            systemd = {
              services.angrr = {
                description = "Auto Nix GC Roots Retention";
                environment.ANGRR_LOG_STYLE = "systemd";
                script = ''
                  ${lib.getExe inputs'.angrr.packages.default} run \
                    --log-level "info" \
                    --no-prompt
                '';
                serviceConfig.Type = "oneshot";
              };
              timers.angrr = {
                timerConfig.OnCalendar = "*-*-* *:00:00";
                wantedBy = [ "timers.target" ];
              };
            };
          };
      };
    };
}
