{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    delta
  ];
  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
}
