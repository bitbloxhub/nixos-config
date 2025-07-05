{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.wezterm = {
      enable = lib.my.mkDisableOption "Wezterm";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.wezterm.enable = config.my.programs.wezterm.enable;
      home.file."./.config/wezterm/wezterm.lua".source = ./wezterm.lua;
    };
}
