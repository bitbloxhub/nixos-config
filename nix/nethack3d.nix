{
  lib,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      pname = "nethack3d";
      version = "1.3.2";

      src = pkgs.fetchurl {
        url = "https://github.com/JamesIV4/nethack-3d/releases/download/${version}/NetHack.3D.${version}.AppImage";
        hash = "sha256-BAy+B5sNypSioCUIU9AVrofQt7sFZwS6pfhp8l324Oc=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      libs = [
        pkgs.glib
        pkgs.nss
        pkgs.nspr
        pkgs.dbus
        pkgs.atk
        pkgs.at-spi2-atk
        pkgs.at-spi2-core
        pkgs.cairo
        pkgs.gtk3
        pkgs.pango
        pkgs.libX11
        pkgs.libXcomposite
        pkgs.libXdamage
        pkgs.libXext
        pkgs.libXfixes
        pkgs.libXrandr
        pkgs.mesa
        pkgs.libgbm
        pkgs.expat
        pkgs.libxcb
        pkgs.libxkbcommon
        pkgs.systemd
        pkgs.alsa-lib
        pkgs.krb5
        pkgs.avahi
        pkgs.gnutls
        pkgs.zlib
      ];
    in
    {
      packages.nethack3d = pkgs.appimageTools.wrapType2 {
        inherit pname version src;
        multiPkgs = null;
        extraPkgs = p: (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs p) ++ libs;
        extraInstallCommands = ''
          install -m 444 -D ${appimageContents}/nethack3d.desktop -t $out/share/applications
          substituteInPlace $out/share/applications/nethack3d.desktop \
            --replace-fail 'Exec=AppRun --no-sandbox %U' "Exec=$out/bin/nethack3d"
          cp -r ${appimageContents}/usr/share/icons $out/share

          source "${pkgs.makeWrapper}/nix-support/setup-hook"

          wrapProgram $out/bin/${pname} \
            --add-flags '--no-sandbox'
        '';

        meta = {
          description = "3D NetHack client powered by WebAssembly and Three.js";
          homepage = "https://github.com/JamesIV4/nethack-3d";
          license = lib.licenses.isc;
          mainProgram = "nethack3d";
          platforms = [ "x86_64-linux" ];
        };
      };
    };

  flake.aspects.gaming =
    { aspect, ... }:
    {
      includes = [ aspect._.nethack3d ];
      _.nethack3d.homeManager =
        {
          self',
          ...
        }:
        {
          home.packages = [ self'.packages.nethack3d ];
        };
    };
}
