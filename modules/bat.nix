{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.bat ];
      _.bat.homeManager = {
        programs.bat.enable = true;
      };
    };
}
