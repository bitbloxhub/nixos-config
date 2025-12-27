{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.zoxide";

  options.programs.zoxide = {
    enable = self.lib.mkDisableOption "Zoxide";
  };

  homeManager.ifEnabled = {
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
