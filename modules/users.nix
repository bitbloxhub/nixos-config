{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
{
  flake.aspects = {
    system = {
      nixos = {
        users.mutableUsers = false;
        users.users.root.hashedPassword = "!";
      };
      _.user =
        {
          username,
          home ? "/home/${username}",
          aspect,
          isTrustedUser ? true,
        }:
        {
          nixos =
            {
              config,
              pkgs,
              ...
            }:
            let
              normalGroups = [
                "audio"
                "video"
                "dialout"
                "networkmanager"
              ];
            in
            {
              imports = [
                inputs.home-manager.nixosModules.home-manager
              ];

              sops.secrets."users/${username}/password".neededForUsers = true;

              users.users.${username} = {
                isNormalUser = true;
                extraGroups = if isTrustedUser then [ "wheel" ] ++ normalGroups else normalGroups;
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
  };
}
