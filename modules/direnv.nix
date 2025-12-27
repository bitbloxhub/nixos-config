{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.direnv";

  options.programs.direnv = {
    enable = self.lib.mkDisableOption "Direnv";
  };

  homeManager.ifEnabled = {
    programs.direnv = {
      enable = true;
      enableNushellIntegration = true;
      config.global = {
        strict_env = true;
        warn_timeout = 0;
      };
    };
  };
}
