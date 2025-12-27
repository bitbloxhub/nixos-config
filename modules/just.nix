{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.just";

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

  options.programs.just = {
    enable = self.lib.mkDisableOption "just";
  };

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      config.home.packages = [
        (pkgs.writeShellScriptBin "sjust" ''
          ${pkgs.just}/bin/just --justfile ${../Justfile} --working-directory ~/nixos-config/
        '')
      ];
    };
}
