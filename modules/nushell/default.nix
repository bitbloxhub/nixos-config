{
  bitbloxhub.nushell = {
    nixos =
      {
        pkgs,
        ...
      }:
      {
        users.defaultUserShell = pkgs.nushell;
      };

    homeManager = {
      programs.nushell = {
        enable = true;
        settings = {
          show_banner = false;
        };
        extraConfig = "source ${./wezterm.nu}";

        environmentVariables = {
          CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
        };
      };

      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
  };
}
