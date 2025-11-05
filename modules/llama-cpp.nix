{
  lib,
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.llama-cpp = {
      enable = self.lib.mkDisableOption "llama.cpp";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = lib.mkIf config.my.programs.llama-cpp.enable [
        (pkgs.llama-cpp.override {
          cudaSupport = config.my.hardware.isNvidia;
        })
      ];
    };
}
