{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
{
  flake.lib.configs = {
    homeManager =
      platform: aspect:
      inputs.home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = withSystem platform (
          { inputs', self', ... }:
          {
            inherit inputs' self';
          }
        );
        modules = [
          self.modules.homeManager.${aspect}
        ];
        pkgs = inputs.nixpkgs.legacyPackages.${platform};
      };
    nixos =
      platform: aspect:
      lib.nixosSystem {
        modules = [
          self.modules.nixos.${aspect}
        ];
        specialArgs = withSystem platform (
          { inputs', self', ... }:
          {
            inherit inputs' self';
          }
        );
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
  };
}
