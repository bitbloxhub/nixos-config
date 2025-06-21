{
  pkgs,
  lib,
  nvidia,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) (
      if (nvidia) then
        [
          "cuda_cccl"
          "cuda_cudart"
          "libcublas"
          "cuda_nvcc"
        ]
      else
        [ ]
    );
}
