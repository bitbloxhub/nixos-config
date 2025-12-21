{
  inputs,
  den,
  bitbloxhub,
  ...
}:
let
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  den.aspects."jonahgam@extreme-creeper" = {
    homeManager = {
      home.username = "jonahgam";
      home.homeDirectory = "/home/jonahgam";
    };
    includes = with bitbloxhub; [
      fd
      nvim
      nushell
      starship
      (theming._.catppuccin "mocha" "mauve" "dark")
      astal-shell
      niri
      atuin
      firefox
      yazi
      zoxide
      git
      delta
      wezterm
      xdg-desktop-portal
      bat
      den.aspects.sjust
      direnv
      nvidia
      (ai._.llama-cpp true)
    ];
  };
  den.homes.x86_64-linux."jonahgam@extreme-creeper" = { };
  hosts."extreme-creeper" = {
    classes = [
      "system-manager"
      # "home-manager"
    ];
    config = {
      my.user.username = "jonahgam";
      my.hostname = "extreme-creeper";
      my.hardware.platform = "x86_64-linux";
      my.nix-system-graphics = {
        enable = true;
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
        extraPackages = [ pkgs.mesa ];
      };
    };
  };
}
