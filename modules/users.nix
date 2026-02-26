{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
{
  flake.aspects = {
    system._.user =
      {
        username,
        home ? "/home/${username}",
        aspect,
      }:
      {
        nixos =
          {
            config,
            pkgs,
            ...
          }:
          {
            imports = [
              inputs.home-manager.nixosModules.home-manager
            ];

            sops.secrets."users/${username}/password".neededForUsers = true;

            users.mutableUsers = false;
            users.users.root.hashedPassword = "!";
            users.users.${username} = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              hashedPasswordFile = config.sops.secrets."users/${username}/password".path;
              inherit home;
            };

            environment.persistence."/persistent".users.${username} = {
              directories = [
                "Downloads"
                "Music"
                "Pictures"
                "Documents"
                "Videos"
                "nixos-config"
                "notes"
                {
                  directory = ".gnupg";
                  mode = "0700";
                }
                {
                  directory = ".ssh";
                  mode = "0700";
                }
                {
                  directory = ".local/share/keyrings";
                  mode = "0700";
                }
                ".local/share/atuin"
                ".local/share/direnv"
                ".local/share/nix"
                ".local/share/zoxide"
                ".local/state"
                ".mozilla"
              ];
              files = [
                ".gitconfig"
                ".config/nushell/history.txt"
                ".config/passwordfile"
              ];
            };

            home-manager.extraSpecialArgs = withSystem pkgs.stdenv.hostPlatform.system (
              { inputs', self', ... }:
              {
                inherit inputs' self';
              }
            );
            # niri-flake issue
            home-manager.sharedModules = lib.mkForce [ ];
            home-manager.users.${username} = {
              imports = [
                self.modules.homeManager.${aspect}
              ];
            };
          };

        homeManager = {
          home = {
            inherit username;
            homeDirectory = home;
          };
        };
      };
  };
}
