{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.starship = {
      enable = lib.my.mkDisableOption "Starship";
      enableNushellIntegration = lib.my.mkDisableOption "Starship Nushell integration";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.starship.enable = config.my.programs.starship.enable;
      programs.starship.enableNushellIntegration = config.my.programs.starship.enableNushellIntegration;
    };
}
