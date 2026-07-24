{
  inputs,
  self,
  ...
}:
{
  flake = {
    aspects =
      { aspects, ... }:
      {
        host_nixos-bill = {
          includes = with aspects; [
            system
            (system._.hostname "nixos-bill")
            (system._.user {
              aspect = "host_nixos-bill";
              username = "jonahgam";
            })
            cli
            gui
            editors
            (rices._.catppuccin { })
          ];
          homeManager = { };
          nixos =
            {
              lib,
              ...
            }:
            {
              imports = [
                inputs.nixos-facter-modules.nixosModules.facter
              ];
              boot = {
                extraModulePackages = [ ];
                initrd = {
                  availableKernelModules = [
                    "ata_piix"
                    "ohci_pci"
                    "ehci_pci"
                    "ahci"
                    "sd_mod"
                    "sr_mod"
                  ];
                  kernelModules = [ ];
                };
                kernelModules = [ ];
                loader = {
                  efi.canTouchEfiVariables = true;
                  systemd-boot.enable = true;
                };
              };
              facter.reportPath = ./facter.json;
              fileSystems = {
                "/" = {
                  device = "none";
                  fsType = "tmpfs";
                  neededForBoot = true;
                  options = [
                    "defaults"
                    "size=25%"
                    "mode=755"
                  ];
                };
                "/boot" = {
                  device = "/dev/disk/by-uuid/9E56-62F5";
                  fsType = "vfat";
                  options = [
                    "fmask=0022"
                    "dmask=0022"
                  ];
                };
                "/mnt" = {
                  device = "/dev/disk/by-uuid/5156916f-cf7e-4b98-ac99-6d9cc8b65e04";
                  fsType = "btrfs";
                  neededForBoot = true;
                };
                "/nix" = {
                  device = "/dev/disk/by-uuid/5156916f-cf7e-4b98-ac99-6d9cc8b65e04";
                  fsType = "btrfs";
                  neededForBoot = true;
                  options = [ "subvol=nix" ];
                };
                "/persistent" = {
                  device = "/dev/disk/by-uuid/5156916f-cf7e-4b98-ac99-6d9cc8b65e04";
                  fsType = "btrfs";
                  neededForBoot = true;
                  options = [ "subvol=persistent" ];
                };
              };
              # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
              # (the default) this is the recommended approach. When using systemd-networkd it's
              # still possible to use this option, but it's recommended to use it in conjunction
              # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
              networking.useDHCP = lib.mkDefault true;
              # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;
              nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
              sops.defaultSopsFile = ./secrets/machine.yaml;
              swapDevices = [ ];
            };
        };
      };
    deploy.nodes.nixos-bill = {
      interactiveSudo = true;
      sshUser = "jonahgam";
    };
    nixosConfigurations."nixos-bill" = self.lib.configs.nixos "x86_64-linux" "host_nixos-bill";
  };
}
