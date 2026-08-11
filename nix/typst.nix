{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.typst.enable = self.lib.mkDisableOption "Typst";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.typst.enable {
        home.packages = [
          pkgs.typst
          pkgs.typstyle
          pkgs.tinymist
        ];
      };
  };
}
