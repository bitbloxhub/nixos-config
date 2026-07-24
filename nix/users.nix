{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  flake.aspects.system = {
    _.user =
      {
        aspect,
        username,
        home ? "/home/${username}",
        isTrustedUser ? true,
      }:
      {
        homeManager.home = {
          inherit username;
          homeDirectory = home;
        };
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
            home-manager = {
              extraSpecialArgs = withSystem pkgs.stdenv.hostPlatform.system (
                { inputs', self', ... }:
                {
                  inherit inputs' self';
                }
              );
              # niri-flake issue, also so we manually import impermenance
              sharedModules = lib.mkForce [ ];
              users.${username}.imports = [
                self.modules.homeManager.${aspect}
              ];
            };
            sops.secrets."users/${username}/password".neededForUsers = true;
            users.users.${username} = {
              inherit home;
              extraGroups = if isTrustedUser then [ "wheel" ] ++ normalGroups else normalGroups;
              hashedPasswordFile = config.sops.secrets."users/${username}/password".path;
              isNormalUser = true;
            };
          };
      };
    nixos.users = {
      mutableUsers = false;
      users.root.hashedPassword = "!";
    };
  };
}
