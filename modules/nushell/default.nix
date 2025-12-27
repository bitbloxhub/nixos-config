{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.nushell";

  options.programs.nushell = {
    enable = self.lib.mkDisableOption "Nushell";
  };

  nixos.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      users.defaultUserShell = pkgs.nushell;
    };

  homeManager.ifEnabled = {
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
}
