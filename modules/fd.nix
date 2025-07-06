{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.fd = {
      enable = lib.my.mkDisableOption "fd";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.fd.enable = config.my.programs.fd.enable;
    };
}
