{
  inputs,
  ...
}:
{
  flake.lib.agsExtraPackagesForPkgs =
    pkgs: with inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}; [
      io
      astal4
      apps
      battery
      mpris
      notifd
      tray
      wireplumber
      cava
      pkgs.libadwaita
    ];
}
