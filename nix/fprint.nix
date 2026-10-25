{
  lib,
  self,
  ...
}:
{
  perSystem =
    {
      lib,
      pkgs,
      ...
    }:
    let
      fprintd = (pkgs.fprintd.override { inherit libfprint; }).overrideAttrs {
        src = fprintdSrc;
      };
      fprintdSrc = pkgs.fetchFromGitHub {
        hash = "sha256-1KwM2xChbqJ5DV4OKC6ZWBboHayLYRZXTLuLgcgrrt8=";
        owner = "bitbloxhub";
        repo = "fprintd";
        rev = "379822093e511561eb8539871cd352a6f76a0b9c";
      };
      libfprint = pkgs.libfprint.overrideAttrs {
        src = libfprintSrc;
        version = "1.94.9";
      };
      libfprintSrc = pkgs.fetchFromGitHub {
        hash = "sha256-WKgun/8r8MsNKbP8yndffjKTXNdDiqNoOvCSi1mELFw=";
        owner = "bitbloxhub";
        repo = "libfprint";
        rev = "0b526b5b4684b671918d801b5b51d519a9512e5f";
      };
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages = {
        inherit fprintd libfprint;
      };
    };

  flake.grove = {
    types.host.options.fprintd.enable = self.lib.mkDisableOption "fprintd";
    projectors.host = {
      nixos =
        host:
        {
          self',
          ...
        }:
        lib.mkIf host.config.fprintd.enable {
          services.fprintd = {
            enable = true;
            package = self'.packages.fprintd;
          };
        };
      systemManager =
        host:
        {
          self',
          ...
        }:
        let
          fprintd = self'.packages.fprintd;
        in
        lib.mkIf host.config.fprintd.enable {
          environment.systemPackages = [ fprintd ];
          systemd.packages = [ fprintd ];
        };
    };
  };
}
