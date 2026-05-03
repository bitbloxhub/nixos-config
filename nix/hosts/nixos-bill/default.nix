{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations."nixos-bill" = self.lib.configs.nixos "x86_64-linux" "host_nixos-bill";

  flake.deploy.nodes.nixos-bill = {
    sshUser = "jonahgam";
    interactiveSudo = true;
  };

  flake.aspects =
    { aspects, ... }:
    {
      host_nixos-bill = {
        nixos =
          {
            lib,
            ...
          }:
          {
            imports = [
              inputs.nixos-facter-modules.nixosModules.facter
            ];
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;

            facter.reportPath = ./facter.json;

            sops = {
              defaultSopsFile = ./secrets/machine.yaml;
            };

            boot.initrd.availableKernelModules = [
              "ata_piix"
              "ohci_pci"
              "ehci_pci"
              "ahci"
              "sd_mod"
              "sr_mod"
            ];
            boot.initrd.kernelModules = [ ];
            boot.kernelModules = [ ];
            boot.extraModulePackages = [ ];

            fileSystems."/" = {
              device = "none";
              fsType = "tmpfs";
              options = [
                "defaults"
                "size=25%"
                "mode=755"
              ];
              neededForBoot = true;
            };

            fileSystems."/mnt" = {
              device = "/dev/disk/by-uuid/5156916f-cf7e-4b98-ac99-6d9cc8b65e04";
              fsType = "btrfs";
              neededForBoot = true;
            };

            fileSystems."/persistent" = {
              device = "/dev/disk/by-uuid/5156916f-cf7e-4b98-ac99-6d9cc8b65e04";
              fsType = "btrfs";
              options = [ "subvol=persistent" ];
              neededForBoot = true;
            };

            fileSystems."/nix" = {
              device = "/dev/disk/by-uuid/5156916f-cf7e-4b98-ac99-6d9cc8b65e04";
              fsType = "btrfs";
              options = [ "subvol=nix" ];
              neededForBoot = true;
            };

            fileSystems."/boot" = {
              device = "/dev/disk/by-uuid/9E56-62F5";
              fsType = "vfat";
              options = [
                "fmask=0022"
                "dmask=0022"
              ];
            };

            swapDevices = [ ];

            # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
            # (the default) this is the recommended approach. When using systemd-networkd it's
            # still possible to use this option, but it's recommended to use it in conjunction
            # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
            networking.useDHCP = lib.mkDefault true;
            # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          };
        homeManager = { };
        includes = with aspects; [
          system
          (system._.hostname "nixos-bill")
          (system._.user {
            username = "jonahgam";
            aspect = "host_nixos-bill";
          })
          cli
          gui
          editors
          (rices._.catppuccin { })
        ];
      };
    };
}
