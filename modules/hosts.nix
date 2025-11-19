{
  lib,
  inputs,
  self,
  config,
  ...
}:
{
  config.flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };
  };

  options.hosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          classes = lib.mkOption {
            type = lib.types.listOf (
              lib.types.enum [
                "nixos"
                "system-manager"
                "home-manager"
              ]
            );
          };
          config = lib.mkOption {
            type = lib.types.submodule self.modules.generic.default;
          };
        };
      }
    );
    default = { };
  };

  config = {
    flake.nixosConfigurations = builtins.mapAttrs (
      _:
      { classes, config, ... }:
      (
        if (builtins.elem "nixos" classes) then
          lib.nixosSystem {
            modules = [
              inputs.catppuccin.nixosModules.catppuccin
              inputs.home-manager.nixosModules.home-manager
              inputs.niri-flake.nixosModules.niri
              inputs.nixos-facter-modules.nixosModules.facter

              inputs.self.modules.generic.default
              inputs.self.modules.nixos.default

              (inputs.self.modules.nixos."host_${config.my.hostname}" or { })

              config
            ];
          }
        else
          null
      )
    ) config.hosts;

    flake.systemConfigs = builtins.mapAttrs (
      _:
      { classes, config, ... }:
      (
        if (builtins.elem "system-manager" classes) then
          inputs.system-manager.lib.makeSystemConfig {
            modules = [
              inputs.nix-system-graphics.systemModules.default

              inputs.self.modules.generic.default
              inputs.self.modules.systemManager.default

              (inputs.self.modules.systemManager."host_${config.my.hostname}" or { })

              config
            ];
          }
        else
          null
      )
    ) config.hosts;

    flake.homeConfigurations = lib.mapAttrs' (
      _:
      { classes, config, ... }:
      {
        name = "${config.my.user.username}@${config.my.hostname}";
        value =
          if (builtins.elem "home-manager" classes) then
            inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = inputs.nixpkgs.legacyPackages.${config.my.hardware.platform};
              modules = [
                inputs.catppuccin.homeModules.catppuccin
                inputs.nixCats.homeModule
                inputs.niri-flake.homeModules.niri
                inputs.betterfox-nix.homeModules.betterfox
                inputs.cosmic-manager.homeManagerModules.cosmic-manager

                inputs.self.modules.generic.default
                inputs.self.modules.homeManager.default

                (inputs.self.modules.systemManager."host_${config.my.hostname}" or { })

                config
              ];
            }
          else
            null;
      }
    ) config.hosts;

    flake.deploy = {
      magicRollback = false;

      nodes = lib.mapAttrs (
        _:
        { classes, config, ... }:
        {
          inherit (config.my) hostname;
          sshUser = config.my.user.username;
          interactiveSudo = true;
          profilesOrder = lib.intersectLists [
            "nixos"
            "system-manager"
            "home-manager"
          ] classes;
          profiles = lib.filterAttrs (_: p: p != null) {
            nixos =
              if (builtins.elem "nixos" classes) then
                {
                  user = "root";
                  path =
                    inputs.deploy-rs.lib.${config.my.hardware.platform}.activate.nixos
                      self.nixosConfigurations.${config.my.hostname};
                }
              else
                null;
            system-manager =
              if (builtins.elem "system-manager" classes) then
                {
                  user = "root";
                  profilePath = "/nix/var/nix/profiles/system-manager-profiles/system-manager";
                  path =
                    inputs.deploy-rs.lib.${config.my.hardware.platform}.activate.custom
                      self.systemConfigs.${config.my.hostname}
                      "./bin/activate";
                }
              else
                null;
            home-manager =
              if (builtins.elem "home-manager" classes) then
                {
                  interactiveSudo = false;
                  profilePath = "${config.my.user.home}/.local/state/nix/profiles/home-manager";
                  path =
                    inputs.deploy-rs.lib.${config.my.hardware.platform}.activate.home-manager
                      self.homeConfigurations."${config.my.user.username}@${config.my.hostname}";
                }
              else
                null;
          };
        }
      ) config.hosts;
    };
  };
}
