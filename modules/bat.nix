{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.bat = {
      enable = lib.my.mkDisableOption "bat";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.bat.enable = config.my.programs.bat.enable;
    };
}
