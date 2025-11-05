{
  lib,
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.delta = {
      enable = self.lib.mkDisableOption "delta";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = lib.mkIf config.my.programs.delta.enable [
        pkgs.delta
      ];
    };
}
