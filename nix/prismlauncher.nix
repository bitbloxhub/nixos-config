{
  lib,
  inputs,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.prismlauncher.enable = self.lib.mkDisableOption "Prism Launcher";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.prismlauncher.enable (
        let
          bw = inputs.nix-bwrapper.lib.mkNixBwrapper pkgs;
        in
        {
          home.packages = [
            (bw.bwrapperEval {
              imports = [
                bw.bwrapperPresets.desktop
              ];
              app = {
                package = pkgs.prismlauncher.override {
                  additionalLibs = [ pkgs.libvlc ];
                  additionalPrograms = [
                    pkgs.ffmpeg
                    pkgs.vlc
                  ];
                };
                addPkgs = [
                  pkgs.kdePackages.qtstyleplugin-kvantum
                  pkgs.fira-code
                ];
              };
              flatpak.manifestFile = pkgs.fetchurl {
                hash = "sha256-1hGHnLClSKsGWu0/LvamvwbTciFqtvSsHgRMGxk834Q=";
                url = "https://raw.githubusercontent.com/flathub/org.prismlauncher.PrismLauncher/067f68f/org.prismlauncher.PrismLauncher.yml";
              };
            }).config.build.package
          ];
        }
      );
  };
}
