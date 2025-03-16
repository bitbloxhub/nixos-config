{
  lib,
  pkgs,
  ...
}:
let
  driver =
    (pkgs.linuxPackages.nvidiaPackages.mkDriver {
      version = "565.77";
      sha256_64bit = "sha256-CnqnQsRrzzTXZpgkAtF7PbH9s7wbiTRNcM0SPByzFHw=";
      sha256_aarch64 = "sha256-LSAYUnhfnK3rcuPe1dixOwAujSof19kNOfdRHE7bToE=";
      openSha256 = "sha256-Fxo0t61KQDs71YA8u7arY+503wkAc1foaa51vi2Pl5I=";
      settingsSha256 = "sha256-VUetj3LlOSz/LB+DDfMCN34uA4bNTTpjDrb6C6Iwukk=";
      persistencedSha256 = "sha256-wnDjC099D8d9NJSp9D0CbsL+vfHXyJFYYgU3CwcqKww=";
    }).override
      {
        libsOnly = true;
        kernel = null;
      };
in
{
  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    system-manager.allowAnyDistro = true;
    system-graphics.enable = true;
    system-graphics.package = driver;
    system-graphics.extraPackages = [ pkgs.mesa ];
  };
}
