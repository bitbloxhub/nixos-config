{
  lib,
  inputs,
  self,
  ...
}:
{

  flake-file.inputs = {
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        astal.follows = "astal";
      };
    };
  };

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
    {
      home.packages = lib.mkIf config.my.programs.astal.enable [
        (inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.ags.override {
          extraPackages = self.lib.agsExtraPackagesForPkgs pkgs;
        })
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.astal-shell
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

  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    let
      pnpmDeps = pkgs.pnpm_10.fetchDeps {
        pname = "astal-shell-pnpm-deps";
        src = ./.;

        fetcherVersion = 2;
        hash = "sha256-jQ9HOO8Cjh66C0ElatYmikTfMenjk5c5vANfZ4q7I2k=";

        # From https://github.com/retrozinndev/colorshell/blob/babfd11/nix/colorshell.nix#L102
        # fetcher version 2 fails if there are no *-exec files in the output
        preFixup = ''
          touch $out/.dummy-exec
        '';
      };
    in
    {
      make-shells.default = {
        name = "nixos-config";
        packages = [
          (inputs'.ags.packages.ags.override {
            extraPackages = self.lib.agsExtraPackagesForPkgs pkgs;
          })
        ];
      };

      packages.astal-shell = pkgs.stdenv.mkDerivation {
        inherit pnpmDeps;

        name = "astal-shell";
        src = ./.;

        nativeBuildInputs = [
          pkgs.nodejs_24
          pkgs.pnpm_10.configHook
          pkgs.wrapGAppsHook4
          pkgs.gobject-introspection
          inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.default
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
      };
    };
}
