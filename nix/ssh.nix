{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types = {
      host.options.ssh.enable = self.lib.mkDisableOption "SSH";
      user.options.ssh.enable = self.lib.mkDisableOption "SSH";
    };
    projectors = {
      host.nixos =
        host:
        lib.mkIf host.config.ssh.enable {
          programs.ssh.startAgent = true;
          services.openssh.enable = true;
        };
      user.homeManager =
        user:
        {
          lib,
          ...
        }:
        lib.mkIf user.config.ssh.enable {
          home = {
            activation.fixSshPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
              run install -d -m 0700 "$HOME/.ssh"
              if [ -L "$HOME/.ssh/config" ]; then
                src="$(readlink -f "$HOME/.ssh/config")"
                run rm -f "$HOME/.ssh/config"
                run install -m 0600 "$src" "$HOME/.ssh/config"
              fi
            '';
            file.".ssh/config".force = true;
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
    };
  };
}
