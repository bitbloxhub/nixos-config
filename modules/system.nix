{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./theming.nix
  ];

  time.timeZone = "UTC";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_DK.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  users.mutableUsers = false;
  users.users.root.hashedPassword = "!";
  users.users.jonahgam = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/etc/nixos/passwordfile";
  };

  security.polkit.enable = true;
}
