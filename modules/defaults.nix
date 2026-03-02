# Provides sane defaults for everything
{
  flake.aspects.system = {
    nixos =
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

    homeManager =
      {
        lib,
        config,
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

        # FIX: For lix activation, see https://github.com/nix-community/home-manager/issues/8786#issuecomment-3964961582
        home.activation.installPackages = lib.mkForce (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            nixProfileRemove home-manager-path
            if [[ -e ${config.home.profileDirectory}/manifest.json ]]; then
              run nix profile install ${config.home.path}
            else
              run nix-env -i ${config.home.path}
            fi
          ''
        );
      };

    systemManager = {
      system-manager.allowAnyDistro = true;
    };
  };
}
