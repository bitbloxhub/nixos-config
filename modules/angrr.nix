{
  lib,
  inputs,
  self,
  ...
}:
let
  angrrConfig = {
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
    profile-policies = {
      system = {
        profile-paths = [
          "/nix/var/nix/profiles/system"
        ];
        keep-latest-n = 1;
        keep-booted-system = true;
        keep-current-system = true;
      };
      system-manager = {
        profile-paths = [
          "/nix/var/nix/profiles/system-manager-profiles/system-manager"
        ];
        keep-latest-n = 1;
      };
      user = {
        profile-paths = [
          "~/.local/state/nix/profiles/profile"
          "/nix/var/nix/profiles/per-user/root/profile"
        ];
        keep-latest-n = 1;
      };
    };
  };
in
inputs.not-denix.lib.module {
  name = "services.angrr";

  flake-file.inputs.angrr = {
    url = "github:linyinfeng/angrr";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
      nix-darwin.follows = "";
      flake-compat.follows = "";
    };
  };

  options.services.angrr = {
    enable = self.lib.mkDisableOption "angrr";
  };

  nixos.ifEnabled = {
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

  systemManager.ifEnabled =
    {
      pkgs,
      inputs',
      ...
    }:
    {
      environment.etc."angrr/config.toml".source =
        (pkgs.formats.toml { }).generate "angrr/config.toml"
          angrrConfig;

      systemd.services.angrr = {
        description = "Auto Nix GC Roots Retention";
        script = ''
          ${lib.getExe inputs'.angrr.packages.default} run \
            --log-level "info" \
            --no-prompt
        '';
        environment.ANGRR_LOG_STYLE = "systemd";
        serviceConfig = {
          Type = "oneshot";
        };
      };

      environment.systemPackages = [ inputs'.angrr.packages.default ];

      systemd.timers.angrr = {
        timerConfig = {
          OnCalendar = "*-*-* *:00:00";
        };
        wantedBy = [ "timers.target" ];
      };
    };
}
