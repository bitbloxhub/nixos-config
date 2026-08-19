{
  lib,
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.spicetify-nix = {
    url = "github:Gerg-L/spicetify-nix";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      systems.follows = "systems";
    };
  };

  perSystem =
    {
      pkgs,
      inputs',
      self',
      ...
    }:
    let
      # TODO: find a better way to do this
      pkgs' = import inputs.nixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in
    {
      packages = {
        spicetify =
          let
            bw = inputs.nix-bwrapper.lib.mkNixBwrapper pkgs';
          in
          (bw.bwrapperEval {
            imports = [
              bw.bwrapperPresets.desktop
            ];
            app = {
              addPkgs = [
                pkgs.fira-code
                pkgs.noto-fonts-cjk-sans
                pkgs.dejavu_fonts
              ];
              package = self'.packages.spicetify-unwrapped;
            };
            flatpak.manifestFile = pkgs.fetchurl {
              hash = "sha256-Pq5dcIdipDvG1AetLGFZRDmsmQVy/H/rquWaKTZ7d5g=";
              url = "https://raw.githubusercontent.com/flathub/com.spotify.Client/07d9eba89258069210ef58dfe7a6c16ecb75349f/com.spotify.Client.json";
            };
          }).config.build.package;
        spicetify-unwrapped = inputs.spicetify-nix.lib.mkSpicetify pkgs' {
          colorScheme = "CatppuccinMocha";
          enabledCustomApps = with inputs'.spicetify-nix.legacyPackages.apps; [
            ncsVisualizer
            localFiles
            {
              name = "stats";
              src = pkgs.fetchzip {
                hash = "sha256-8CO5M0EM0n/aXD79Xsis0eiBpxj2zVLfu49/kbO+m+M=";
                # https://github.com/harbassan/spicetify-apps/releases
                url = "https://github.com/harbassan/spicetify-apps/releases/download/stats-v1.1.3/spicetify-stats.release.zip";
              };
            }
            {
              name = "eternal-jukebox";
              src = pkgs.fetchzip {
                hash = "sha256-0rJ7spxOaUi7r/40isiq794vodIUNXduAB83Jy0/Vpg=";
                # https://github.com/Pithaya/spicetify-apps-dist/tree/dist/eternal-jukebox
                url = "https://github.com/Pithaya/spicetify-apps-dist/archive/16c9822372229a35b5206386088fe575bd805874.zip";
              };
            }

          ];
          enabledExtensions = with inputs'.spicetify-nix.legacyPackages.extensions; [
            keyboardShortcut
          ];
          theme = inputs'.spicetify-nix.legacyPackages.themes.text // {
            additionalCss = builtins.readFile ./user.css;
          };
          wayland = true;
        };
      };
    };

  flake.grove = {
    types.user.options.spicetify.enable = self.lib.mkDisableOption "Spicetify";
    projectors.user.homeManager =
      user:
      {
        self',
        ...
      }:
      lib.mkIf user.config.spicetify.enable {
        home.packages = [ self'.packages.spicetify ];
      };
  };
}
