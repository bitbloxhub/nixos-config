{
  lib,
  inputs,
  ...
}:
{
  flake.modules.generic.default =
    {
      config,
      ...
    }:
    {
      options.my.user = {
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

  flake.modules.nixos.default =
    {
      config,
      ...
    }:
    {
      users.mutableUsers = false;
      users.users.root.hashedPassword = "!";
      users.users.${config.my.user.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = "/etc/nixos/passwordfile";
        home = config.my.user.home;
      };

      home-manager.users.${config.my.user.username} = {
        imports = [
          inputs.catppuccin.homeModules.catppuccin
          inputs.nixCats.homeModule

          inputs.self.modules.generic.default
          inputs.self.modules.homeManager.default

          { my = config.my; }
        ];
      };
    };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      home.username = "${config.my.user.username}";
      home.homeDirectory = "${config.my.user.home}";
    };
}
