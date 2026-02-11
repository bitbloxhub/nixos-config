{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
{
  flake.lib.configs = {
    nixos =
      platform: aspect:
      lib.nixosSystem {
        specialArgs = withSystem platform (
          { inputs', self', ... }:
          {
            inherit inputs' self';
          }
        );
        modules = [
          self.modules.nixos.${aspect}
        ];
      };
    systemManager =
      platform: aspect:
      inputs.system-manager.lib.makeSystemConfig {
        extraSpecialArgs = withSystem platform (
          { inputs', self', ... }:
          {
            inherit inputs' self';
          }
        );
        modules = [
          self.modules.systemManager.${aspect}
        ];
      };
    homeManager =
      platform: aspect:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${platform};
        extraSpecialArgs = withSystem platform (
          { inputs', self', ... }:
          {
            inherit inputs' self';
          }
        );
        modules = [
          self.modules.homeManager.${aspect}
        ];
      };
  };
}
