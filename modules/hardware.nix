{
  lib,
  ...
}:
{
  flake.modules.generic.default =
    {
      config,
      ...
    }:
    {
      options.my.hardware = {
        facter-report = lib.mkOption {
          type = lib.types.path;
        };
        platform = lib.mkOption {
          type = lib.types.str;
        };
        isNvidia = lib.mkEnableOption "Nvidia";
      };
      config.my.allowedUnfreePackages = lib.mkIf config.my.hardware.isNvidia [
        "cuda_cccl"
        "cuda_cudart"
        "libcublas"
        "cuda_nvcc"
      ];
    };

  flake.modules.nixos.default =
    {
      config,
      ...
    }:
    {
      facter.reportPath = config.my.hardware.facter-report;
    };
}
