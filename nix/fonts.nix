{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.fonts.enable = self.lib.mkDisableOption "fonts";
    projectors.user = {
      homeManager =
        user:
        {
          pkgs,
          ...
        }:
        lib.mkIf user.config.fonts.enable {
          gtk = {
            enable = true;
            font = {
              package = pkgs.fira-code;
              name = "Fira Code";
            };
          };
        };
      nixos =
        user:
        {
          pkgs,
          ...
        }:
        lib.mkIf user.config.fonts.enable {
          fonts.packages = [
            pkgs.fira-code
            pkgs.nerd-fonts.symbols-only
          ];
        };
    };
  };
}
