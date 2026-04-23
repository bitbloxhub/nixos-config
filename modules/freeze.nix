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
            theme = "catppuccin-mocha";
            background = "#1e1e2e";

            window = false;
            shadow = false;
            padding = [
              20
              40
              20
              20
            ];
            margin = 0;

            font = {
              family = "Fira Code";
              size = 14;
            };

            line_height = 1;
          };
        };
    };
}
