{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.fonts ];
      _.fonts = {
        homeManager =
          {
            pkgs,
            ...
          }:
          {
            gtk = {
              enable = true;
              font = {
                package = pkgs.fira-code;
                name = "Fira Code";
              };
            };
          };
        nixos =
          {
            pkgs,
            ...
          }:
          {
            fonts.packages = [
              pkgs.fira-code
              pkgs.nerd-fonts.symbols-only
            ];
          };
      };
    };
}
