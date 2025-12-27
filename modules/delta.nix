{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.delta";

  options.programs.delta = {
    enable = self.lib.mkDisableOption "delta";
  };

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.delta
      ];
    };
}
