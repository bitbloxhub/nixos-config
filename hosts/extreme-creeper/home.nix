{
  pkgs,
  system-manager,
  ...
}:

{
  home.username = "jonahgam";
  home.homeDirectory = "/home/jonahgam";

  home.packages = [
    pkgs.nixfmt-rfc-style
    pkgs.stylua
    system-manager.packages."${pkgs.system}".default
  ];

  imports = [
    ../../home
  ];

  xdg.enable = true;
  xdg.mime.enable = true;
  targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
