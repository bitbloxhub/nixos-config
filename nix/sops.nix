{
  lib,
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix/pull/779/merge";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.sops
        ];

        shellHook = ''
          export SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_ed25519_sops
        '';
      };
    };

  flake.grove = {
    types = {
      host.options.sops.enable = self.lib.mkDisableOption "sops";
      user.options.sops.enable = self.lib.mkDisableOption "sops";
    };
    projectors = {
      host.nixos = host: {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        config = lib.mkIf host.config.sops.enable {
          sops.age.sshKeyFile = "/persistent/etc/ssh/ssh_host_ed25519_sops";
        };
      };
      user.homeManager =
        user:
        {
          config,
          ...
        }:
        {
          imports = [ inputs.sops-nix.homeManagerModules.sops ];
          config = lib.mkIf user.config.sops.enable {
            sops.age.sshKeyFile = "${config.home.homeDirectory}/.ssh/id_ed25519_sops";
          };
        };
    };
  };
}
