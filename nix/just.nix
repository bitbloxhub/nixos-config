{
  lib,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default.packages = [
        pkgs.just
      ];
    };

  flake.grove = {
    types.user.options.just.enable = self.lib.mkDisableOption "just";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.just.enable {
        home.packages = [
          (pkgs.writeShellScriptBin "sjust" ''
            cd "$HOME/nixos-config"
            exec ${pkgs.just}/bin/just "$@"
          '')
        ];
      };
  };
}
