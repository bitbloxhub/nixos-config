{
  lib,
  inputs,
  ...
}:
{
  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        (inputs.nix-bwrapper.lib.${pkgs.system}.bwrapper (
          {
            config,
            ...
          }:
          {
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
            # Currently, it uses ro-bind and not ro-bind-try for /run/current-system,
            # which breaks non-NixOS systems
            fhsenv.bwrap.baseArgs = lib.mkForce [
              "--new-session"
              "--tmpfs /home"
              "--tmpfs /mnt"
              "--tmpfs /run"
              "--ro-bind-try /run/current-system /run/current-system"
              "--ro-bind-try /run/booted-system /run/booted-system"
              "--ro-bind-try /run/opengl-driver /run/opengl-driver"
              "--ro-bind-try /run/opengl-driver-32 /run/opengl-driver-32"
              "--bind \"$XDG_RUNTIME_DIR/doc/by-app/${config.app.id}\" \"$XDG_RUNTIME_DIR/doc\""
            ];
          }
        ))
      ];
    };
}
