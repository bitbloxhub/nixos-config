{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.atuin";

  options.programs.atuin = {
    enable = self.lib.mkDisableOption "Atuin";
  };

  homeManager.ifEnabled = {
    programs.atuin.enable = true;
    programs.atuin.enableNushellIntegration = true;
    programs.atuin.flags = [ "--disable-up-arrow" ];
  };
}
