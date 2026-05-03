{
  inputs,
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

  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.sops ];
      _.sops = {
        nixos = {
          imports = [ inputs.sops-nix.nixosModules.sops ];
          sops = {
            age.sshKeyFile = "/persistent/etc/ssh/ssh_host_ed25519_sops";
          };
        };
        homeManager =
          {
            config,
            ...
          }:
          {
            imports = [ inputs.sops-nix.homeManagerModules.sops ];
            sops = {
              age.sshKeyFile = "${config.home.homeDirectory}/.ssh/id_ed25519_sops";
            };
          };
      };
    };
}
