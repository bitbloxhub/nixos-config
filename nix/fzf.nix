{
  lib,
  ...
}:
{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.fzf ];
      _.fzf.homeManager = {
        programs.fzf = {
          enable = true;
          historyWidget.command = "";
          colors.bg = lib.mkForce "";
        };
      };
    };
}
