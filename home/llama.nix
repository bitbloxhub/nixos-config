{
  pkgs,
  lib,
  nvidia,
  ...
}:

{
  home.packages = with pkgs; [
    (llama-cpp.override { cudaSupport = nvidia; })
  ];
}
