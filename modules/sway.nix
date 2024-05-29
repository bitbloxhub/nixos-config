{ config, lib, pkgs, ... }:

{
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
  };
}
