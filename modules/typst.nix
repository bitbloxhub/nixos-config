{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.typst";

  options.programs.typst = {
    enable = self.lib.mkDisableOption "Typst";
  };

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.typst
        pkgs.typstyle
        pkgs.tinymist
      ];
    };
}
