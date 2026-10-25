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
          fonts.fontconfig.enable = true;
          gtk = {
            enable = true;
            font.name = "Fira Code";
          };
          home.packages = [
            pkgs.fira-code
            pkgs.nerd-fonts.symbols-only
          ];
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
