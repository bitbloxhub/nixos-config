{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.ripgrep";

  options.programs.ripgrep = {
    enable = self.lib.mkDisableOption "ripgrep";
  };

  homeManager.ifEnabled = {
    programs.ripgrep.enable = true;
  };
}
