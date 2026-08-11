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
      lib.mkIf user.config.prismlauncher.enable {
        home.packages = [
          ((inputs.nix-bwrapper.lib.mkNixBwrapper pkgs).bwrapperEval {
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
            mounts.read = [
              "/run/systemd"
              "/sys/kernel/mm/hugepages"
              "/sys/kernel/mm/transparent_hugepage"
            ];
          }).config.build.package
        ];
      };
  };
}
