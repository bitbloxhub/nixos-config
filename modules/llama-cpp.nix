{
  flake.aspects = {
    cli =
      { aspect, ... }:
      {
        includes = [ aspect._.llama-cpp ];
        _.llama-cpp.homeManager =
          {
            pkgs,
            ...
          }:
          {
            home.packages = [
              pkgs.llama-cpp
            ];
          };
      };

    # Nicest way i could think of to do this
    nvidia.homeManager = {
      nixpkgs.overlays = [
        (_final: prev: {
          llama-cpp = prev.llama-cpp.override {
            cudaSupport = true;
          };
        })
      ];
    };
  };
}
