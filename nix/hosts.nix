{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
{
  flake = {
    grove = {
      types.host.options.users = lib.mkOption {
        default = [ ];
        type = lib.types.listOf lib.types.str;
      };
      projectors.host = {
        nixos =
          host:
          {
            ...
          }:
          {
            imports = map (userId: self.grove.finalized.user.nixos.${userId}) host.config.users;
          };
        systemManager = _host: { };
      };
    };
    lib.configs = {
      homeManager =
        platform: userId:
        inputs.home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = withSystem platform (
            { inputs', self', ... }:
            {
              inherit inputs' self';
            }
          );
          modules = [
            self.grove.finalized.user.homeManager.${userId}
          ];
          pkgs = inputs.nixpkgs.legacyPackages.${platform};
        };
      nixos =
        platform: hostId:
        lib.nixosSystem {
          modules = [
            self.grove.finalized.host.nixos.${hostId}
          ];
          specialArgs = withSystem platform (
            { inputs', self', ... }:
            {
              inherit inputs' self';
            }
          );
        };
      systemManager =
        platform: hostId:
        inputs.system-manager.lib.makeSystemConfig {
          extraSpecialArgs = withSystem platform (
            { inputs', self', ... }:
            {
              inherit inputs' self';
            }
          );
          modules = [
            self.grove.finalized.host.systemManager.${hostId}
          ];
        };
    };
  };
}
