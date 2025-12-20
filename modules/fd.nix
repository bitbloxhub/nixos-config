{
  config,
  self,
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.fd = {
      enable = self.lib.mkDisableOption "fd";
    };
  };

  flake.aspects.user =
    {
      aspect,
      ...
    }:
    {
      homeManager = { };
      _.fd.homeManager =
        {
          config,
          ...
        }:
        {
          programs.fd.enable = config.my.programs.fd.enable;
        };
      includes = [ aspect._.fd ];
    };
}
