{
  flake.aspects =
    { aspects, ... }:
    {
      nvidia = {
        includes = [
          (aspects.system._.unfree [
            "cuda_cccl"
            "cuda_cudart"
            "libcublas"
            "cuda_nvcc"
          ])
        ];
      };
    };
}
