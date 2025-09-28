{
  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    let
      firefox-second-sidebar = pkgs.fetchFromGitHub {
        owner = "aminought";
        repo = "firefox-second-sidebar";
        rev = "0b77c8bc4e59e93acafeece99033a627fb68f67a";
        hash = "sha256-sSclGRI5NnAuE+quzKuYHS547Qx37mtcAu89jpXUAt4=";
      };
    in
    {
      home.file.".mozilla/firefox/nix/chrome/JS/second_sidebar.uc.mjs" = {
        source = "${firefox-second-sidebar}/src/second_sidebar.uc.mjs";
      };
      home.file.".mozilla/firefox/nix/chrome/JS/second_sidebar" = {
        source = "${firefox-second-sidebar}/src/second_sidebar";
      };
    };
}
