{
  lib,
  inputs,
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.astal = {
      enable = self.lib.mkDisableOption "Astal shell";
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
      npmDeps = pkgs.importNpmLock.buildNodeModules {
        nodejs = pkgs.nodejs_24;
        npmRoot = ./.;
        package = prodPackage;
      };

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
        (inputs.ags.packages.${pkgs.system}.ags.override {
          extraPackages = self.lib.agsExtraPackagesForPkgs pkgs;
        })
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
          ]
          ++ (self.lib.agsExtraPackagesForPkgs pkgs);

          installPhase = ''
            mv style.css style.old.css
            ${pkgs.esbuild}/bin/esbuild --bundle style.old.css --outfile=style.css --supported:nesting=false
            mkdir -p $out/bin
            ags bundle app.ts $out/bin/astal-shell
          '';
        })
      ];

      home.file."${config.xdg.dataHome}/astal-shell/icons/" = {
        source = ./icons;
        recursive = true;
      };

      programs.niri.settings = {
        spawn-at-startup = lib.mkIf config.my.programs.astal.enable [
          {
            command = [
              "astal-shell"
            ];
          }
        ];
        binds = {
          "Mod+Return".action.spawn = [
            "ags"
            "toggle"
            "launcher"
          ];
        };
      };
    };
}
