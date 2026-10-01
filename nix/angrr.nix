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
  flake-file.inputs = {
    angrr = {
      url = "github:linyinfeng/angrr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fast-nix-gc = {
      url = "github:Mic92/fast-nix-gc";
      inputs = {
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  flake.grove.projectors.host = {
    nixos = _host: {
      imports = [
        inputs.angrr.nixosModules.angrr
        inputs.fast-nix-gc.nixosModules.default
      ];
      services = {
        angrr = {
          enable = true;
          settings = angrrConfig;
          enableNixGcIntegration = false;
          timer = {
            enable = true;
            dates = "*-*-* *:00:00";
          };
        };
        fast-nix-gc = {
          enable = true;
          automatic = true;
          dates = "weekly";
        };
      };
      systemd.services.angrr = {
        before = [ "fast-nix-gc.service" ];
        wantedBy = [ "fast-nix-gc.service" ];
      };
    };
    systemManager =
      _host:
      {
        pkgs,
        inputs',
        ...
      }:
      {
        environment = {
          etc."angrr/config.toml".source = (pkgs.formats.toml { }).generate "angrr/config.toml" angrrConfig;
          systemPackages = [
            inputs'.angrr.packages.default
            inputs'.fast-nix-gc.packages.default
          ];
        };
        systemd = {
          services = {
            angrr = {
              before = [ "fast-nix-gc.service" ];
              description = "Auto Nix GC Roots Retention";
              environment.ANGRR_LOG_STYLE = "systemd";
              script = ''
                ${lib.getExe inputs'.angrr.packages.default} run \
                  --log-level "info" \
                  --no-prompt
              '';
              serviceConfig.Type = "oneshot";
              wantedBy = [ "fast-nix-gc.service" ];
            };
            fast-nix-gc = {
              description = "Fast Nix Garbage Collector";
              script = ''
                ${lib.getExe inputs'.fast-nix-gc.packages.default}
              '';
              serviceConfig = {
                StandardError = "journal";
                StandardOutput = "journal";
                Type = "oneshot";
              };
            };
          };
          timers = {
            angrr = {
              timerConfig.OnCalendar = "*-*-* *:00:00";
              wantedBy = [ "timers.target" ];
            };
            fast-nix-gc = {
              timerConfig = {
                OnCalendar = "weekly";
                Persistent = true;
              };
              wantedBy = [ "timers.target" ];
            };
          };
        };
      };
  };
}
