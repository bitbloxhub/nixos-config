{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.jq = {
      enable = lib.my.mkDisableOption "jq";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.jq.enable = config.my.programs.jq.enable;
    };
}
