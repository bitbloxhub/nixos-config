{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.wlr-which-key ];
      _.wlr-which-key.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.wlr-which-key
          ];
          programs.niri.settings.binds."Mod+Semicolon".action.spawn = [
            "wlr-which-key"
            "mouse"
          ];
          xdg.configFile."wlr-which-key/mouse.yaml".source = ./mouse.yaml;
        };
    };
}
