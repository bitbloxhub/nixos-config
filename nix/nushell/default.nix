{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.nushell ];
      _.nushell = {
        homeManager = {
          home.persistence."/persistent".files = [ ".config/nushell/history.txt" ];
          programs = {
            carapace = {
              enable = true;
              enableNushellIntegration = true;
            };
            nushell = {
              enable = true;
              settings.show_banner = false;
              environmentVariables.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
              extraConfig = "source ${./wezterm.nu}";
            };
          };
        };
        nixos =
          {
            pkgs,
            ...
          }:
          {
            users.defaultUserShell = pkgs.nushell;
          };
      };
    };
}
