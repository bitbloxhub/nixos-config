{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.bat";

  options.programs.bat = {
    enable = self.lib.mkDisableOption "bat";
  };

  homeManager.ifEnabled = {
    programs.bat.enable = true;
  };
}
