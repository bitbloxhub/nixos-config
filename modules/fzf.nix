{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.fzf = {
      enable = lib.my.mkDisableOption "fzf";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.fzf.enable = config.my.programs.fzf.enable;
    };
}
