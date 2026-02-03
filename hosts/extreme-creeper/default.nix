{
  inputs,
  ...
}:
let
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  hosts."extreme-creeper" = {
    classes = [
      "system-manager"
      "home-manager"
    ];
    config = {
      my.user.username = "jonahgam";
      my.hostname = "extreme-creeper";
      my.hardware.platform = "x86_64-linux";
      my.nix-system-graphics = {
        enable = true;
        driver =
          (pkgs.linuxPackages.nvidiaPackages.mkDriver {
            version = "580.119.02";
            sha256_64bit = "sha256-gCD139PuiK7no4mQ0MPSr+VHUemhcLqerdfqZwE47Nc=";
            sha256_aarch64 = "sha256-eYcYVD5XaNbp4kPue8fa/zUgrt2vHdjn6DQMYDl0uQs=";
            openSha256 = "sha256-l3IQDoopOt0n0+Ig+Ee3AOcFCGJXhbH1Q1nh1TEAHTE=";
            settingsSha256 = "sha256-sI/ly6gNaUw0QZFWWkMbrkSstzf0hvcdSaogTUoTecI=";
            persistencedSha256 = "sha256-j74m3tAYON/q8WLU9Xioo3CkOSXfo1CwGmDx/ot0uUo=";
          }).override
            {
              libsOnly = true;
              kernel = null;
            };
        extraPackages = [ pkgs.mesa ];
      };
    };
  };
}
