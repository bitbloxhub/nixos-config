{
  lib,
  self,
  withSystem,
  ...
}:
{
  flake.grove.projectors = {
    host.nixos =
      host:
      {
        pkgs,
        ...
      }:
      {
        # Home Manager's NixOS module needs these paths linked for portal definitions.
        environment.pathsToLink = [
          "/share/applications"
          "/share/xdg-desktop-portal"
        ];
        home-manager = {
          extraSpecialArgs = withSystem pkgs.stdenv.hostPlatform.system (
            { inputs', self', ... }:
            {
              inherit inputs' self';
            }
          );
          # niri-flake issue, also so we manually import impermanence.
          sharedModules = lib.mkForce [ ];
          users = lib.listToAttrs (
            map (userId: {
              name = builtins.head (lib.splitString "@" userId);
              value = self.grove.finalized.user.homeManager.${userId};
            }) host.config.users
          );
        };
      };
    user.homeManager = _user: {
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
  };
}
