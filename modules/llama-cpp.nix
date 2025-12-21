{
  lib,
  ...
}:
{
  flake.modules.generic.aaaa = {
    isNvidia = lib.mkEnableOption "Nvidia";
  };

  bitbloxhub.ai._.llama-cpp = cuda: {
    includes =
      if cuda then
        (lib.traceVal [
          {
            homeManager =
              {
                pkgs,
                ...
              }:
              {
                home.packages = [
                  (pkgs.llama-cpp.override {
                    cudaSupport = cuda;
                  })
                ];
              };
          }
        ])
      else
        [ ];
  };
}
