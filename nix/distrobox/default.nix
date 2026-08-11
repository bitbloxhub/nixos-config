{
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.distrobox.enable = self.lib.mkDisableOption "distrobox";
    projectors.user.homeManager =
      user:
      {
        lib,
        pkgs,
        ...
      }:
      lib.mkIf user.config.distrobox.enable {
        home = {
          packages = [
            pkgs.yay
            (lib.hiPrio (
              pkgs.writeShellScriptBin "distrobox-host-exec" (builtins.readFile ./distrobox-host-exec)
            ))
          ];
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
