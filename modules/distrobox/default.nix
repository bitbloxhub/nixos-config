{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.distrobox ];
      _.distrobox.homeManager =
        {
          pkgs,
          lib,
          ...
        }:
        {
          home.packages = [
            pkgs.yay
            (lib.hiPrio (
              pkgs.writeShellScriptBin "distrobox-host-exec" (builtins.readFile ./distrobox-host-exec)
            ))
          ];
          programs.distrobox = {
            enable = true;
            settings = {
              container_manager = "podman";
              container_image_default = "ghcr.io/archlinux/archlinux:base";
              container_name_default = "arch";
            };
          };
        };
    };
}
