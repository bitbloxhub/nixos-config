{
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.desktops.cosmic = {
      enable = self.lib.mkDisableOption "COSMIC";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      wayland.desktopManager.cosmic.enable = config.my.desktops.cosmic.enable;
    };
}
