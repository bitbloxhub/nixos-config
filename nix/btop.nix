{
  flake.aspects = {
    cli =
      { aspect, ... }:
      {
        includes = [ aspect._.btop ];
        _.btop.homeManager = {
          programs.btop = {
            enable = true;
            settings = {
              vim_keys = true;
              theme_background = false;
              update_ms = 500;
            };
          };
        };
      };

    nvidia.homeManager = {
      nixpkgs.overlays = [
        (_final: prev: {
          btop = prev.btop.override {
            cudaSupport = true;
          };
        })
      ];
    };
  };
}
