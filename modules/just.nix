{
  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        (pkgs.writeShellScriptBin "sjust" ''
          just --justfile ${../Justfile} --working-directory ~/nixos-config/
        '')
      ];
    };
}
