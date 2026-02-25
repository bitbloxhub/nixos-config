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
      _.impermanence.nixos = {
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
          ];
        };
      };
    };
}
