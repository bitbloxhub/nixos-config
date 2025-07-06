{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.atuin = {
      enable = lib.my.mkDisableOption "Atuin";
      enableNushellIntegration = lib.my.mkDisableOption "Atuin Nushell integration";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.atuin.enable = config.my.programs.atuin.enable;
      programs.atuin.enableNushellIntegration = config.my.programs.atuin.enableNushellIntegration;
      programs.atuin.flags = [ "--disable-up-arrow" ];
    };
}
