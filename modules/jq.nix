{
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.jq = {
      enable = self.lib.mkDisableOption "jq";
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
