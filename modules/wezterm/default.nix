{
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.wezterm = {
      enable = self.lib.mkDisableOption "Wezterm";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    let
      resurrect = pkgs.stdenv.mkDerivation {
        name = "resurrect";
        src = pkgs.fetchFromGitHub {
          owner = "MLFlexer";
          repo = "resurrect.wezterm";
          rev = "47ce553e07bb2c183d10487c56c406454aa50f36";
          hash = "sha256-j7BIvJV7brkqWTtdWE/v9FnXRuHH0+934MTDCFNLEdY=";
        };
        patches = builtins.map (x: ./resurrect_patches/${x}) (
          builtins.attrNames (builtins.readDir ./resurrect_patches)
        );
        installPhase = ''
          cp -r . $out
        '';
      };
    in
    {
      programs.wezterm.enable = config.my.programs.wezterm.enable;
      home.file."./.config/wezterm/resurrect" = {
        source = resurrect + "/plugin/resurrect";
        recursive = true;
      };
      home.file."./.config/wezterm/resurrect/init.lua".source = resurrect + "/plugin/init.lua";
      home.file."./.config/wezterm/wezterm.lua".source = ./wezterm.lua;
    };
}
