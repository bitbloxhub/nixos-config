{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.freeze ];
      _.freeze.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            (pkgs.symlinkJoin {
              name = "freeze";
              paths = with pkgs; [
                charm-freeze
                librsvg
              ];
            })
          ];

          xdg.configFile."freeze/user.json".text = builtins.toJSON {
            background = "#1e1e2e";
            font = {
              family = "Fira Code";
              size = 14;
            };
            line_height = 1;
            margin = 0;
            padding = [
              20
              40
              20
              20
            ];
            shadow = false;
            theme = "catppuccin-mocha";
            window = false;
          };
        };
    };
}
