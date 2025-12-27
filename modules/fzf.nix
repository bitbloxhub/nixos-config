{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.fzf";

  options.programs.fzf = {
    enable = self.lib.mkDisableOption "fzf";
  };

  homeManager.ifEnabled = {
    programs.fzf.enable = true;
  };
}
