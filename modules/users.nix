{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
inputs.not-denix.lib.module {
  name = "user";

  options =
    {
      config,
      ...
    }:
    {
      user = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "My username on the system.";
        };
        home = lib.mkOption {
          type = lib.types.path;
          default = "/home/${config.my.user.username}";
          description = "My home directory.";
        };
      };
    };

  nixos.always =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      users.mutableUsers = false;
      users.users.root.hashedPassword = "!";
      users.users.${config.my.user.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = "/etc/nixos/passwordfile";
        inherit (config.my.user) home;
      };

      home-manager.extraSpecialArgs = withSystem config.my.hardware.platform (
        { inputs', self', ... }:
        {
          inherit inputs' self';
        }
      );
      # niri-flake issue
      home-manager.sharedModules = lib.mkForce [ ];
      home-manager.users.${config.my.user.username} = {
        imports = [
          self.modules.generic.default
          self.modules.homeManager.default

          { inherit (config) my; }
        ];
      };
    };

  homeManager.always =
    {
      config,
      ...
    }:
    {
      home.username = "${config.my.user.username}";
      home.homeDirectory = "${config.my.user.home}";
    };
}
