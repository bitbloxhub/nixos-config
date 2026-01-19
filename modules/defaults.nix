# Provides sane defaults for everything
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
      # Why does niri-flake do this?
      services.gnome.gcr-ssh-agent.enable = false;
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
      inputs',
      ...
    }:
    {
      home.packages = [
        inputs'.system-manager.packages.default
        inputs'.deploy-rs.packages.default
      ];
      xdg.enable = true;
      xdg.mime.enable = true;
      targets.genericLinux.enable = true;
      # I use nix-system-graphics.
      targets.genericLinux.gpu.enable = false;
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
