{
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.desktops.cosmic.greeter = {
      enable = self.lib.mkDisableOption "COSMIC";
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
