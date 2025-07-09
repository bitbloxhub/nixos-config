{
  lib,
  inputs,
  ...
}:
{
  lib.mkSystem = classes: config: {
    flake.nixosConfigurations.${config.my.hostname} =
      if (builtins.elem "nixos" classes) then
        lib.nixosSystem {
          modules = [
            inputs.catppuccin.nixosModules.catppuccin
            inputs.home-manager.nixosModules.home-manager

            inputs.self.modules.generic.default
            inputs.self.modules.nixos.default

            (inputs.self.modules.nixos."host_${config.my.hostname}" or { })

            config
          ];
        }
      else
        null;
    flake.systemConfigs.${config.my.hostname} =
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
        null;
    flake.homeConfigurations."${config.my.user.username}@${config.my.hostname}" =
      if (builtins.elem "home-manager" classes) then
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${config.my.hardware.platform};
          modules = [
            inputs.catppuccin.homeModules.catppuccin
            inputs.nixCats.homeModule

            inputs.self.modules.generic.default
            inputs.self.modules.homeManager.default

            (inputs.self.modules.systemManager."host_${config.my.hostname}" or { })

            config
          ];
          inherit lib;
        }
      else
        null;
  };
}
