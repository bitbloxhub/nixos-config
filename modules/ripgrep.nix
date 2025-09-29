{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.ripgrep = {
      enable = lib.my.mkDisableOption "ripgrep";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.ripgrep.enable = config.my.programs.ripgrep.enable;
    };
}
