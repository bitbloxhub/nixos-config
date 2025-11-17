{
  lib,
  inputs,
  self,
  config,
  ...
}:
{
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
  };
}
