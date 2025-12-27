{
  lib,
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "hardware";

  flake-file.inputs.nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

  options.hardware = {
    facter-report = lib.mkOption {
      type = lib.types.path;
    };
    platform = lib.mkOption {
      type = lib.types.str;
    };
    isNvidia = lib.mkEnableOption "Nvidia";
  };

  generic.always =
    {
      config,
      ...
    }:
    {
      config.my.allowedUnfreePackages = lib.mkIf config.my.hardware.isNvidia [
        "cuda_cccl"
        "cuda_cudart"
        "libcublas"
        "cuda_nvcc"
      ];
    };

  nixos.always =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.nixos-facter-modules.nixosModules.facter
      ];

      facter.reportPath = config.my.hardware.facter-report;
    };
}
