{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.distrobox ];
      _.distrobox.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [ pkgs.yay ];
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
