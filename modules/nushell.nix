{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.nushell = {
      enable = lib.my.mkDisableOption "Nushell";
    };
  };

  flake.modules.nixos.default =
    { pkgs, config, ... }:
    {
      users.defaultUserShell = lib.mkIf config.my.programs.nushell.enable pkgs.nushell;
    };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.nushell.enable = config.my.programs.nushell.enable;
      programs.nushell.settings = {
        show_banner = false;
      };

      programs.nushell.environmentVariables = {
        CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
      };

      programs.carapace.enable = config.my.programs.nushell.enable;
      programs.carapace.enableNushellIntegration = config.my.programs.nushell.enable;
    };
}
