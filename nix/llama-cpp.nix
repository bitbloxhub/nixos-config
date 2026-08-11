{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user =
      { config, ... }:
      {
        config = lib.mkIf config.llama-cpp.enable {
          unfree.packages = [
            "cuda_cccl"
            "cuda_cudart"
            "libcublas"
            "cuda_nvcc"
          ];
        };
        options.llama-cpp.enable = self.lib.mkDisableOption "llama.cpp";
      };
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.llama-cpp.enable {
        home.packages = [ pkgs.llama-cpp ];
        nixpkgs.overlays = [
          (_final: prev: {
            llama-cpp =
              (prev.llama-cpp.override {
                cudaSupport = true;
              }).overrideAttrs
                (old: {
                  cmakeFlags = (old.cmakeFlags or [ ]) ++ [
                    "-DGGML_CPU_ALL_VARIANTS:BOOL=FALSE"
                  ];
                });
          })
        ];
      };
  };
}
