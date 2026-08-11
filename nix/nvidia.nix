{
  lib,
  ...
}:
{
  flake.grove.types.host =
    {
      config,
      ...
    }:
    {
      config = lib.mkIf config.nvidia.enable {
        unfree.packages = [
          "cuda_cccl"
          "cuda_cudart"
          "libcublas"
          "cuda_nvcc"
        ];
      };
      options.nvidia.enable = lib.mkEnableOption "NVIDIA";
    };
}
