{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.zathura ];
      _.zathura.homeManager = {
        programs.zathura = {
          enable = true;
          options = {
            recolor = false;
          };
        };
      };
    };
}
