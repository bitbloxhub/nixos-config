{
  lib,
  ...
}:
lib.my.deepMerge
  (lib.my.mkSystem [ "nixos" ] {
    my.user.username = "jonahgam";
    my.hostname = "nixos-bill";
    my.hardware.platform = "x86_64-linux";
    my.virtualization.qemu.guest.enable = true;
  })
  {
    flake.modules.nixos.host_nixos-bill = {
      imports = [
        ./hardware-configuration.nix
      ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };
  }
