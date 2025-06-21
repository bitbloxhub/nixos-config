{
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.just
    (pkgs.writeShellScriptBin "sjust" ''
      just --justfile ${../Justfile} --working-directory ~/nixos-config/
    '')
  ];
}
