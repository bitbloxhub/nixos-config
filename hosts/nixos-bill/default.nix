_:
{
  hosts."nixos-bill" = {
    classes = [ "nixos" ];
    config = {
      my.user.username = "jonahgam";
      my.hostname = "nixos-bill";
      my.hardware.platform = "x86_64-linux";
      my.hardware.facter-report = ./facter.json;
    };
  };

  flake.modules.nixos.host_nixos-bill = {
    imports = [
      ./hardware-configuration.nix
    ];
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
