{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.distrobox ];
      _.distrobox.homeManager =
        {
          lib,
          pkgs,
          ...
        }:
        {
          home = {
            packages = [
              pkgs.yay
              (lib.hiPrio (
                pkgs.writeShellScriptBin "distrobox-host-exec" (builtins.readFile ./distrobox-host-exec)
              ))
            ];
            # Used by things in the distrobox, not ideal to have them globally,
            # but changing the distrobox home dir stops it from using other dotfiles I want.
            persistence."/persistent".directories = [
              ".local/bin"
              ".local/lib"
            ];
          };
          programs.distrobox = {
            enable = true;
            settings = {
              container_image_default = "ghcr.io/archlinux/archlinux:base";
              container_manager = "podman";
              container_name_default = "arch";
            };
          };
        };
    };
}
