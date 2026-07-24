{
  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.ssh ];
      _.ssh = {
        homeManager =
          {
            lib,
            ...
          }:
          {
            home = {
              activation.fixSshPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
                run install -d -m 0700 "$HOME/.ssh"
                if [ -L "$HOME/.ssh/config" ]; then
                  src="$(readlink -f "$HOME/.ssh/config")"
                  run rm -f "$HOME/.ssh/config"
                  run install -m 0600 "$src" "$HOME/.ssh/config"
                fi
              '';
              # ssh config permission fixes from https://github.com/nix-community/home-manager/issues/322#issuecomment-3730266609
              file = {
                # home-manager wrongly thinks it doesn't manage (and thus shouldn't clobber) this file due to the activation script
                ".ssh/config".force = true;
              };
            };
            programs.ssh = {
              enable = true;
              settings = {
                "*".controlMaster = "no";
                "github.com".identityFile = "~/.ssh/id_ed25519_github";
                "tangled.sh".identityFile = "~/.ssh/id_ed25519_tangled";
              };
              enableDefaultConfig = false;
            };
          };
        nixos = {
          programs.ssh.startAgent = true;
          services.openssh.enable = true;
        };
      };
    };
}
