{
  den.aspects.sjust.homeManager =
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
