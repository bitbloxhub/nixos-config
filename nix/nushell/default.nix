{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.nushell.enable = self.lib.mkDisableOption "Nushell";
    projectors.user = {
      homeManager =
        user:
        lib.mkIf user.config.nushell.enable {
          home.persistence."/persistent".files = [ ".config/nushell/history.txt" ];
          programs = {
            carapace = {
              enable = true;
              enableNushellIntegration = true;
            };
            nushell = {
              enable = true;
              settings.show_banner = false;
              environmentVariables.CARAPACE_BRIDGES = "zsh,fish,bash,inshellsenses";
              extraConfig = "source ${./wezterm.nu}";
            };
          };
        };
      nixos =
        user:
        { pkgs, ... }:
        lib.mkIf user.config.nushell.enable {
          users.users.${user.config.username}.shell = pkgs.nushell;
        };
    };
  };
}
