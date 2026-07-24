{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.wezterm ];
      _.wezterm.homeManager =
        {
          pkgs,
          ...
        }:
        let
          resurrect = pkgs.stdenv.mkDerivation {
            installPhase = ''
              cp -r . $out
            '';
            name = "resurrect";
            patches = builtins.map (x: ./resurrect_patches/${x}) (
              builtins.attrNames (builtins.readDir ./resurrect_patches)
            );
            src = pkgs.fetchFromGitHub {
              hash = "sha256-j7BIvJV7brkqWTtdWE/v9FnXRuHH0+934MTDCFNLEdY=";
              owner = "MLFlexer";
              repo = "resurrect.wezterm";
              rev = "47ce553e07bb2c183d10487c56c406454aa50f36";
            };
          };
        in
        {
          catppuccin.wezterm.enable = false;
          home.file = {
            "./.config/wezterm/resurrect" = {
              recursive = true;
              source = resurrect + "/plugin/resurrect";
            };
            "./.config/wezterm/resurrect/init.lua".source = resurrect + "/plugin/init.lua";
            "./.config/wezterm/wezterm.lua".source = ./wezterm.lua;
          };
          programs.wezterm.enable = true;
        };
    };
}
