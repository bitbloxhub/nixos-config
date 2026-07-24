# Provides sane defaults for everything
{
  flake.aspects.system = {
    homeManager =
      {
        lib,
        config,
        inputs',
        ...
      }:
      {
        home = {
          # FIX: For lix activation, see https://github.com/nix-community/home-manager/issues/8786#issuecomment-3964961582
          activation.installPackages = lib.mkForce (
            lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              nixProfileRemove home-manager-path
              if [[ -e ${config.home.profileDirectory}/manifest.json ]]; then
                run nix profile install ${config.home.path}
              else
                run nix-env -i ${config.home.path}
              fi
            ''
          );
          packages = [
            inputs'.system-manager.packages.default
            inputs'.deploy-rs.packages.default
          ];
          stateVersion = "23.11";
        };
        programs.home-manager.enable = true;
        targets.genericLinux = {
          enable = true;
          # I use nix-system-graphics.
          gpu.enable = false;
        };
        xdg = {
          enable = true;
          mime.enable = true;
        };
      };
    nixos =
      {
        pkgs,
        ...
      }:
      {
        environment.systemPackages = [
          pkgs.git
        ];
        home-manager = {
          useGlobalPkgs = false;
          useUserPackages = true;
        };
        networking = {
          firewall.enable = false;
          networkmanager.enable = true;
        };
        services = {
          avahi = {
            enable = true;
            nssmdns4 = true;
          };
          # Why does niri-flake do this?
          gnome.gcr-ssh-agent.enable = false;
        };
        system.stateVersion = "23.11";
      };
    systemManager.system-manager.allowAnyDistro = true;
  };
}
