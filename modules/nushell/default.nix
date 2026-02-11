{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.nushell ];
      _.nushell = {
        nixos =
          {
            pkgs,
            ...
          }:
          {
            users.defaultUserShell = pkgs.nushell;
          };

        homeManager = {
          programs.nushell.enable = true;
          programs.nushell.settings = {
            show_banner = false;
          };
          programs.nushell.extraConfig = "source ${./wezterm.nu}";

          programs.nushell.environmentVariables = {
            CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
          };

          programs.carapace.enable = true;
          programs.carapace.enableNushellIntegration = true;
        };
      };
    };
}
