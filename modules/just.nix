{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      make-shells.default = {
        packages = [
          pkgs.just
        ];
      };
    };

  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        (pkgs.writeShellScriptBin "sjust" ''
          ${pkgs.just}/bin/just --justfile ${../Justfile} --working-directory ~/nixos-config/
        '')
      ];
    };
}
