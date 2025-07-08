{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.fuzzel = {
      enable = lib.my.mkDisableOption "fuzzel";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.fuzzel = {
        inherit (config.my.programs.fuzzel) enable;
        settings.main = {
          font = "Fira Code:size=10";
          lines = 20;
          width = 60;
          horizontal-pad = 40;
          vertical-pad = 16;
          inner-pad = 6;
        };
      };
    };
}
