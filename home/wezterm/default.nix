{
  pkgs,
  ...
}:

{
  programs.wezterm.enable = true;
  programs.wezterm.package = pkgs.symlinkJoin {
    name = "wezterm-always-new-process";
    paths = [ pkgs.wezterm ];
    # adapted from https://discourse.nixos.org/t/wrapping-a-desktop-file-force-vlc-to-use-wayland/49548/4
    # the desktop file is already a store path so we need to copy it before editing
    # see https://github.com/NixOS/nixpkgs/blob/2ccfe3a/pkgs/by-name/we/wezterm/package.nix#L92
    postBuild = ''
      mv $out/share/applications/org.wezfurlong.wezterm.desktop{,.orig}
      substitute $out/share/applications/org.wezfurlong.wezterm.desktop{.orig,} \
          --replace-fail "Exec=wezterm start --cwd ." "Exec=$out/bin/wezterm start --cwd . --always-new-process"
    '';
  };
  home.file."./.config/wezterm/wezterm.lua".source = ./wezterm.lua;
}
