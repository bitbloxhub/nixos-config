{ config, lib, pkgs, ... }:

{
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "green";
  # work around https://github.com/catppuccin/nix/issues/192
  services.displayManager.sddm.catppuccin.enable =  false;
}
