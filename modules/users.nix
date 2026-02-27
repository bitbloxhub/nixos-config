{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
{
  flake.aspects = {
    system._.user =
      {
        username,
        home ? "/home/${username}",
        aspect,
      }:
      {
        nixos =
          {
            config,
            pkgs,
            ...
          }:
          {
            imports = [
              inputs.home-manager.nixosModules.home-manager
            ];

            sops.secrets."users/${username}/password".neededForUsers = true;

            users.mutableUsers = false;
            users.users.root.hashedPassword = "!";
            users.users.${username} = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              hashedPasswordFile = config.sops.secrets."users/${username}/password".path;
              inherit home;
            };

            home-manager.extraSpecialArgs = withSystem pkgs.stdenv.hostPlatform.system (
              { inputs', self', ... }:
              {
                inherit inputs' self';
              }
            );
            # niri-flake issue, also so we manually import impermenance
            home-manager.sharedModules = lib.mkForce [ ];
            home-manager.users.${username} = {
              imports = [
                self.modules.homeManager.${aspect}
              ];
            };
          };

        homeManager = {
          home = {
            inherit username;
            homeDirectory = home;
          };
        };
      };
  };
}
