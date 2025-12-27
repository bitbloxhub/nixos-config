{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.jq";

  options.programs.jq = {
    enable = self.lib.mkDisableOption "jq";
  };

  homeManager.ifEnabled = {
    programs.jq.enable = true;
  };
}
