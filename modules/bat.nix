{
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.bat = {
      enable = self.lib.mkDisableOption "bat";
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
