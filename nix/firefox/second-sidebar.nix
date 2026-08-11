{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user =
      {
        config,
        ...
      }:
      {
        options.firefox.second-sidebar.enable = self.lib.mkDisableOption "Firefox Second Sidebar" // {
          default = config.firefox.enable;
        };
      };
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      let
        firefox-second-sidebar = pkgs.fetchFromGitHub {
          hash = "sha256-HKJ7+yUBso6opIFPsyR3d6r+GB9pX5hHPflP0p+bstU=";
          owner = "Satoxyan";
          repo = "firefox-second-sidebar";
          rev = "74aca2f60065537e2fc33f4b9d05cac70325dead";
        };
      in
      lib.mkIf user.config.firefox.second-sidebar.enable {
        home.file = {
          ".mozilla/firefox/nix/chrome/JS" = {
            recursive = true;
            source = "${firefox-second-sidebar}/src/JS";
          };
          ".mozilla/firefox/nix/chrome/second_sidebar.css".source =
            "${firefox-second-sidebar}/src/userChrome.css";
        };
      };
  };
}
