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
          password ? null,
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

              users.users.${username} = {
                isNormalUser = true;
                extraGroups = if isTrustedUser then [ "wheel" ] ++ normalGroups else normalGroups;
                inherit home;
              }
              // (
                if password == null then
                  {
                    hashedPasswordFile = config.sops.secrets."users/${username}/password".path;
                  }
                else
                  {
                    initialPassword = password;
                  }
              );

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
            }
            // lib.optionalAttrs (password == null) {
              sops.secrets."users/${username}/password".neededForUsers = true;
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
