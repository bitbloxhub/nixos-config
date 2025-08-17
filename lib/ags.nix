{
  inputs,
  ...
}:
{
  lib.agsExtraPackagesForPkgs =
    pkgs: with inputs.ags.packages.${pkgs.system}; [
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
