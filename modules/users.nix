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
        inherit (config.my.user) home;
      };

      # niri-flake issue
      home-manager.sharedModules = lib.mkForce [ ];
      home-manager.users.${config.my.user.username} = {
        imports = [
          inputs.catppuccin.homeModules.catppuccin
          inputs.nixCats.homeModule
          inputs.niri-flake.homeModules.niri
          inputs.betterfox-nix.homeModules.betterfox
          inputs.cosmic-manager.homeManagerModules.cosmic-manager

          inputs.self.modules.generic.default
          inputs.self.modules.homeManager.default

          { inherit (config) my; }
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
