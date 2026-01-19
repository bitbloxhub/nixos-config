{
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.firefox";

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    let
      firefox-second-sidebar = pkgs.fetchFromGitHub {
        owner = "Satoxyan";
        repo = "firefox-second-sidebar";
        rev = "74aca2f60065537e2fc33f4b9d05cac70325dead";
        hash = "sha256-HKJ7+yUBso6opIFPsyR3d6r+GB9pX5hHPflP0p+bstU=";
      };
    in
    {
      home.file.".mozilla/firefox/nix/chrome/JS" = {
        source = "${firefox-second-sidebar}/src/second_sidebar.uc.mjs";
        recursive = true;
      };
      home.file.".mozilla/firefox/nix/chrome/second_sidebar.css" = {
        source = "${firefox-second-sidebar}/src/userChrome.css";
      };
    };
}
