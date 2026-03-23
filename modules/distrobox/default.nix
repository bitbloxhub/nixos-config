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

          # Used by things in the distrobox, not ideal to have them globally,
          # but changing the distrobox home dir stops it from using other dotfiles I want.
          home.persistence."/persistent".directories = [
            ".local/bin"
            ".local/lib"
            ".pi"
            ".agent-browser"
          ];
        };
    };
}
