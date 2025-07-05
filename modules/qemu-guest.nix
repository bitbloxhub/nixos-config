{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.virtualization.qemu.guest = {
      enable = lib.mkEnableOption "Qemu guest";
    };
  };

  flake.modules.nixos.default =
    {
      config,
      ...
    }:
    {
      boot.initrd.availableKernelModules = lib.mkIf config.my.virtualization.qemu.guest.enable [
        "virtio_net"
        "virtio_pci"
        "virtio_mmio"
        "virtio_blk"
        "virtio_scsi"
        "9p"
        "9pnet_virtio"
      ];
      boot.initrd.kernelModules = lib.mkIf config.my.virtualization.qemu.guest.enable [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
        "virtio_gpu"
      ];
    };
}
