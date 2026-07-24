{
  lib,
  inputs,
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

            pulseClientConfig = pkgs.writeText "pulse-client.conf" ''
              enable-shm=no
            '';
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
              env = {
                PULSE_CLIENTCONFIG = "/run/flatpak/pulse/config";
                PULSE_SERVER = "unix:/run/flatpak/pulse/native";
              };
              package = self'.packages.spicetify-unwrapped;
            };
            fhsenv.bwrap.additionalArgs = [
              "--dir /run/flatpak"
              "--dir /run/flatpak/pulse"
              ''--ro-bind-try "$XDG_RUNTIME_DIR/pulse/native" /run/flatpak/pulse/native''
              "--ro-bind ${pulseClientConfig} /run/flatpak/pulse/config"
              ''--symlink ../../flatpak/pulse "$XDG_RUNTIME_DIR/pulse"''
            ];
            flatpak.manifestFile = pkgs.fetchurl {
              hash = "sha256-Pq5dcIdipDvG1AetLGFZRDmsmQVy/H/rquWaKTZ7d5g=";
              url = "https://raw.githubusercontent.com/flathub/com.spotify.Client/07d9eba89258069210ef58dfe7a6c16ecb75349f/com.spotify.Client.json";
            };
            # FIX: workaround for https://github.com/Naxdy/nix-bwrapper/issues/50
            sockets.pulseaudio = lib.mkForce false;
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

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.spicetify ];
      _.spicetify.homeManager =
        {
          self',
          ...
        }:
        {
          home.packages = [ self'.packages.spicetify ];
        };
    };
}
