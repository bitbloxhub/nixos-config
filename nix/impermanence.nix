{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
    inputs = {
      home-manager.follows = "home-manager";
      nixpkgs.follows = "nixpkgs";
    };
  };

  flake.grove = {
    types.user.options.impermanence.enable = lib.mkEnableOption "impermanence";
    projectors.user = {
      homeManager =
        _user:
        {
          ...
        }:
        {
          imports = [ (import "${inputs.impermanence}/home-manager.nix") ];
          home = {
            _nixosModuleImported = true;
            persistence."/persistent".directories = [
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
              ".local/share/nix"
              ".local/state"
              ".cache"
              ".bwrapper"
            ];
          };
        };
      nixos = user: {
        imports = [ inputs.impermanence.nixosModules.impermanence ];
        config = lib.mkIf user.config.impermanence.enable {
          environment.persistence."/persistent" = {
            enable = true;
            directories = [
              "/var/log"
              "/var/lib/bluetooth"
              "/var/lib/nixos"
              "/var/lib/systemd/coredump"
              "/etc/NetworkManager/system-connections"
            ];
            files = [
              "/etc/machine-id"
              "/etc/ssh/ssh_host_ed25519_key"
              {
                file = "/etc/ssh/ssh_host_ed25519_key.pub";
                method = "symlink";
              }
              "/etc/ssh/ssh_host_rsa_key"
              "/etc/ssh/ssh_host_rsa_key.pub"
              "/etc/ssh/ssh_host_ed25519_sops"
              "/etc/ssh/ssh_host_ed25519_sops.pub"
            ];
            hideMounts = true;
          };
        };
      };
    };
  };
}
