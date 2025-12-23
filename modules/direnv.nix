{
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.direnv = {
      enable = self.lib.mkDisableOption "Direnv";
      enableNushellIntegration = self.lib.mkDisableOption "Direnv Nushell integration";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.direnv = {
        enable = config.my.programs.direnv.enable;
        enableNushellIntegration = config.my.programs.direnv.enableNushellIntegration;
        config.global = {
          strict_env = true;
          warn_timeout = 0;
        };
      };
    };
}
