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
        nixos = {
          imports = [
            ./hardware-configuration.nix
            inputs.nixos-facter-modules.nixosModules.facter
          ];
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          facter.reportPath = ./facter.json;
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
