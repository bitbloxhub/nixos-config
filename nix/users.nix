{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  flake.grove = {
    types.user.options = {
      home = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
      };
      isTrustedUser = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
      username = lib.mkOption {
        type = lib.types.str;
      };
    };
    projectors.user = {
      homeManager = user: {
        home = {
          homeDirectory =
            if user.config.home == null then "/home/${user.config.username}" else user.config.home;
          username = user.config.username;
        };
      };
      nixos =
        user:
        {
          config,
          ...
        }:
        let
          home = if user.config.home == null then "/home/${username}" else user.config.home;
          normalGroups = [
            "audio"
            "video"
            "dialout"
            "networkmanager"
          ];
          username = user.config.username;
        in
        {
          imports = [
            inputs.home-manager.nixosModules.home-manager
          ];
          sops.secrets."users/${username}/password".neededForUsers = true;
          users.users.${username} = {
            inherit home;
            extraGroups = if user.config.isTrustedUser then [ "wheel" ] ++ normalGroups else normalGroups;
            hashedPasswordFile = config.sops.secrets."users/${username}/password".path;
            isNormalUser = true;
          };
        };
    };
  };
}
