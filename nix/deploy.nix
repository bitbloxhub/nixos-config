{
  lib,
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs = {
      flake-compat.follows = "";
      nixpkgs.follows = "nixpkgs";
      utils.follows = "flake-utils";
    };
  };

  flake.deploy = {
    magicRollback = false;
    nodes = lib.mkMerge (
      lib.flatten [
        (lib.mapAttrsToList (hostname: config: {
          ${hostname} = {
            inherit hostname;
            profiles.system = {
              path =
                inputs.deploy-rs.lib.${config.config.nixpkgs.hostPlatform.system}.activate.nixos
                  self.nixosConfigurations.${hostname};
              user = "root";
            };
          };
        }) self.nixosConfigurations)
        (lib.mapAttrsToList (hostname: config: {
          ${hostname} = {
            inherit hostname;
            profiles.system-manager = {
              path =
                inputs.deploy-rs.lib.${config.config.nixpkgs.hostPlatform}.activate.custom
                  self.systemConfigs.${hostname}
                  "./bin/activate";
              profilePath = "/nix/var/nix/profiles/system-manager-profiles/system-manager";
              user = "root";
            };
          };
        }) self.systemConfigs)
        (lib.mapAttrsToList
          (
            usernameAndHostname: config:
            let
              hostname = lib.elemAt usernameAndHostname' 1;
              username = lib.elemAt usernameAndHostname' 0;
              usernameAndHostname' = lib.splitString "@" usernameAndHostname;
            in
            {
              ${hostname} = {
                inherit hostname;
                profiles."home-manager-${username}" = {
                  path =
                    inputs.deploy-rs.lib.${config.config.nixpkgs.system}.activate.home-manager
                      self.homeConfigurations.${usernameAndHostname};
                  profilePath = "/home/${username}/.local/state/nix/profiles/home-manager";
                  user = username;
                };
              };
            }
          )
          (
            lib.filterAttrs (name: _value: (lib.length (lib.splitString "@" name)) == 2) self.homeConfigurations
          )
        )
      ]
    );
  };
}
