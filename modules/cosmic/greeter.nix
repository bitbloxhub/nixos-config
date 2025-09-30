{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.desktops.cosmic.greeter = {
      enable = lib.my.mkDisableOption "COSMIC";
    };
  };

  flake.modules.nixos.default =
    {
      config,
      ...
    }:
    {
      services.displayManager.cosmic-greeter.enable = config.my.desktops.cosmic.greeter.enable;
    };
}
