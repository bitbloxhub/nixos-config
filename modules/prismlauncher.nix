{
  inputs,
  ...
}:
{
  flake.aspects.gaming =
    { aspect, ... }:
    {
      includes = [ aspect._.prismlauncher ];
      _.prismlauncher.homeManager =
        {
          pkgs,
          ...
        }:
        {

          home.packages = [
            ((inputs.nix-bwrapper.lib.mkNixBwrapper pkgs).bwrapperEval {
              app = {
                package = pkgs.prismlauncher.override {
                  additionalPrograms = [
                    pkgs.ffmpeg
                    pkgs.vlc
                  ];
                  additionalLibs = [ pkgs.libvlc ];
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
