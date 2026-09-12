{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user =
      {
        config,
        ...
      }:
      {
        config.unfree.packages = lib.mkIf config.obsidian.enable [
          "obsidian"
        ];
        options.obsidian.enable = self.lib.mkDisableOption "Obsidian";
      };
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.obsidian.enable {
        home = {
          packages = [
            pkgs.obsidian
          ];
          persistence."/persistent".directories = [ "obsidian" ];
        };
      };
  };
}
