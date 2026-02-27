{
  inputs,
  ...
}:
{
  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.impermanence ];
      _.impermanence = {
        nixos = {
          imports = [ inputs.impermanence.nixosModules.impermanence ];
          environment.persistence."/persistent" = {
            enable = true;
            hideMounts = true;
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
          };
        };

        homeManager = {
          imports = [ (import "${inputs.impermanence}/home-manager.nix") ];
          home._nixosModuleImported = true; # impermanence needs this
          home.persistence."/persistent" = {
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
              ".local/share/nix"
              ".local/state"
              ".bwrapper"
            ];
          };
        };
      };
    };
}
