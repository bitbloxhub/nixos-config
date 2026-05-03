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
      nixpkgs.follows = "nixpkgs";
      utils.follows = "flake-utils";
      flake-compat.follows = "";
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
              user = "root";
              path =
                inputs.deploy-rs.lib.${config.config.nixpkgs.hostPlatform.system}.activate.nixos
                  self.nixosConfigurations.${hostname};
            };
          };
        }) self.nixosConfigurations)
        (lib.mapAttrsToList (hostname: config: {
          ${hostname} = {
            inherit hostname;
            profiles.system-manager = {
              user = "root";
              profilePath = "/nix/var/nix/profiles/system-manager-profiles/system-manager";
              path =
                inputs.deploy-rs.lib.${config.config.nixpkgs.hostPlatform}.activate.custom
                  self.systemConfigs.${hostname}
                  "./bin/activate";
            };
          };
        }) self.systemConfigs)
        (lib.mapAttrsToList
          (
            usernameAndHostname: config:
            let
              usernameAndHostname' = lib.splitString "@" usernameAndHostname;
              username = lib.elemAt usernameAndHostname' 0;
              hostname = lib.elemAt usernameAndHostname' 1;
            in
            {
              ${hostname} = {
                inherit hostname;
                profiles."home-manager-${username}" = {
                  user = username;
                  profilePath = "/home/${username}/.local/state/nix/profiles/home-manager";
                  path =
                    inputs.deploy-rs.lib.${config.config.nixpkgs.system}.activate.home-manager
                      self.homeConfigurations.${usernameAndHostname};
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
