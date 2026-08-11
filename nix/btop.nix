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
        config = lib.mkIf config.btop.enable {
          unfree.packages = [
            "cuda_cccl"
            "cuda_cudart"
            "libcublas"
            "cuda_nvcc"
          ];
        };
        options.btop.enable = self.lib.mkDisableOption "btop";
      };
    projectors.user.homeManager =
      user:
      lib.mkIf user.config.btop.enable {
        nixpkgs.overlays = [
          (_final: prev: {
            btop = prev.btop.override {
              cudaSupport = true;
            };
          })
        ];
        programs.btop = {
          enable = true;
          settings = {
            theme_background = false;
            update_ms = 500;
            vim_keys = true;
          };
        };
      };
  };
}
