{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.llama-cpp";

  options.programs.llama-cpp = {
    enable = self.lib.mkDisableOption "llama.cpp";
  };

  homeManager.ifEnabled =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = [
        (pkgs.llama-cpp.override {
          cudaSupport = config.my.hardware.isNvidia;
        })
      ];
    };
}
