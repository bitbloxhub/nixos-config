{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.direnv = {
      enable = lib.my.mkDisableOption "Direnv";
      enableNushellIntegration = lib.my.mkDisableOption "Direnv Nushell integration";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.direnv.enable = config.my.programs.direnv.enable;
      programs.direnv.enableNushellIntegration = config.my.programs.direnv.enableNushellIntegration;
    };
}
