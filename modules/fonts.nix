{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "fonts";

  options.fonts = {
    enable = self.lib.mkDisableOption "fonts";
  };

  nixos.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      fonts.packages = [
        pkgs.fira-code
        pkgs.nerd-fonts.symbols-only
      ];
    };

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      gtk = {
        enable = true;
        font = {
          package = pkgs.fira-code;
          name = "Fira Code";
        };
      };
    };
}
