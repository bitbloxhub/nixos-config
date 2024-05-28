{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jonahgam";
  home.homeDirectory = "/home/jonahgam";

  home.packages = with pkgs; [
    floorp
    keepassxc
    fira-code
    htop
    vivid
    eza
  ];

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "green";

  qt = {
    enable = true;
    style = {
      package = pkgs.catppuccin-kde.override {
        flavour = [ "mocha" ];
        accents = [ "green" ];
      };
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
    export LS_COLORS=$(vivid generate catppuccin-mocha)
    '';
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
    git = true;
    icons = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    extraConfig = {
      init.defaultBranch = "main";
      user.email = "45184892+bitbloxhub@users.noreply.github.com";
      user.name = "bitbloxhub";
    };
  };

  programs.kitty = {
    enable = true;
    font.name = "Fira Code Light";
    font.size = 12;
    theme = "Catppuccin-Mocha";
    extraConfig = ''
    confirm_os_window_close 0
    '';
  };

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
