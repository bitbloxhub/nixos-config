{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.fd";

  options.programs.fd = {
    enable = self.lib.mkDisableOption "fd";
  };

  homeManager.ifEnabled = {
    programs.fd.enable = true;
  };
}
