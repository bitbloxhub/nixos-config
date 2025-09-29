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
}
