{
  inputs,
  ...
}:
let
  agsExtraPackagesForPkgs =
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
in
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

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.astal-shell ];
      _.astal-shell.homeManager =
        {
          config,
          pkgs,
          inputs',
          self',
          ...
        }:
        {
          home.packages = [
            (inputs'.ags.packages.ags.override {
              extraPackages = agsExtraPackagesForPkgs pkgs;
            })
            self'.packages.astal-shell
          ];

          home.file."${config.xdg.dataHome}/astal-shell/icons/" = {
            source = ./icons;
            recursive = true;
          };

          programs.niri.settings = {
            spawn-at-startup = [
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
    };

  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    let
      pnpm = pkgs.pnpm_10;
      src = ./.;
      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit src pnpm;
        pname = "astal-shell-pnpm-deps";

        fetcherVersion = 3;
        hash = "sha256-+6d6uC++ColsHwcHmDmDYPLsS1L6efH10s/q3cp0Xo4=";

        # From https://github.com/retrozinndev/colorshell/blob/babfd11/nix/colorshell.nix#L102
        # fetcher version 3 ALSO fails if there are no *-exec files in the output
        # See https://github.com/NixOS/nixpkgs/commit/ee4e6c1 for storePath
        preFixup = ''
          touch $storePath/.dummy-exec
        '';
      };
    in
    {
      make-shells.default = {
        packages = [
          (inputs'.ags.packages.ags.override {
            extraPackages = agsExtraPackagesForPkgs pkgs;
          })
        ];
      };

      packages.astal-shell = pkgs.stdenv.mkDerivation {
        inherit src pnpmDeps;

        name = "astal-shell";

        nativeBuildInputs = [
          pkgs.nodejs_25
          pnpm
          pkgs.pnpmConfigHook
          pkgs.wrapGAppsHook4
          pkgs.gobject-introspection
          inputs'.ags.packages.default
        ];

        buildInputs = [
          pkgs.glib
          pkgs.gjs
        ]
        ++ (agsExtraPackagesForPkgs pkgs);

        installPhase = ''
          mv style.css style.old.css
          ${pkgs.esbuild}/bin/esbuild --bundle style.old.css --outfile=style.css --supported:nesting=false
          mkdir -p $out/bin
          ags bundle app.ts $out/bin/astal-shell
        '';
      };
    };
}
