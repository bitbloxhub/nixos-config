{
  flake.modules.nixos.default =
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

  flake.modules.homeManager.default =
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
