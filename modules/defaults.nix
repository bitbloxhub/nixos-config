# Provides sane defaults for everything
{
  lib,
  inputs,
  ...
}:
{
  flake.modules.nixos.default =
    {
      pkgs,
      ...
    }:
    {
      networking.networkmanager.enable = true;
      networking.firewall.enable = false;
      services.openssh.enable = true;
      programs.ssh.startAgent = true;
      services.avahi.enable = true;
      services.avahi.nssmdns4 = true;

      environment.systemPackages = [
        pkgs.git
      ];

      home-manager.useGlobalPkgs = false;
      home-manager.useUserPackages = true;

      system.stateVersion = "23.11";
    };

  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ inputs.system-manager.packages."${pkgs.system}".default ];
      xdg.enable = true;
      xdg.mime.enable = true;
      targets.genericLinux.enable = true;
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
    };

  flake.modules.systemManager.default =
    {
      config,
      ...
    }:
    {
      nixpkgs.hostPlatform = config.my.hardware.platform;
      system-manager.allowAnyDistro = true;
    };
}
