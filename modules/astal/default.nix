{
  lib,
  inputs,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.astal = {
      enable = lib.my.mkDisableOption "Astal shell";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    let
      package = builtins.fromJSON (builtins.readFile ./package.json);
      prodPackage = builtins.removeAttrs package [ "devDependencies" ];
      npmDeps = builtins.trace inputs.ags.packages.${pkgs.system}.gjsPackage.outPath (
        pkgs.importNpmLock.buildNodeModules {
          nodejs = pkgs.nodejs_24;
          npmRoot = ./.;
          package = prodPackage;
        }
      );

      astalShellSource = pkgs.runCommand "astal-shell-source" { } ''
        mkdir -p $out
        cp -r ${builtins.filterSource (path: _type: baseNameOf path != "node_modules") ./.}/* $out/
        mkdir -p $out/node_modules
        cp -r ${npmDeps}/node_modules/* $out/node_modules/
        mkdir -p $out/node_modules/astal
        cp -r ${inputs.astal}/lang/gjs/src/* $out/node_modules/astal/
      '';
    in
    {
      home.packages = lib.mkIf config.my.programs.astal.enable [
        (pkgs.stdenv.mkDerivation {
          name = "astal-shell";

          src = astalShellSource;

          nativeBuildInputs = [
            pkgs.wrapGAppsHook
            pkgs.gobject-introspection
            inputs.ags.packages.${pkgs.system}.default
          ];

          buildInputs = [
            pkgs.glib
            pkgs.gjs
            inputs.astal.packages.${pkgs.system}.io
            inputs.astal.packages.${pkgs.system}.astal4
          ];

          installPhase = ''
            mv style.css style.old.css
            ${pkgs.esbuild}/bin/esbuild --bundle style.old.css --outfile=style.css
            mkdir -p $out/bin
            ags bundle app.ts $out/bin/astal-shell
          '';
        })
      ];

      programs.niri.settings.spawn-at-startup = lib.mkIf config.my.programs.astal.enable [
        {
          command = [
            "astal-shell"
          ];
        }
      ];
    };
}
