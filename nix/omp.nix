{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.omp.enable = self.lib.mkDisableOption "omp";
    projectors.user.homeManager =
      user:
      {
        inputs',
        ...
      }:
      lib.mkIf user.config.omp.enable {
        # TODO: replace with nixpkgs one after updating due, temporarily using llm-agents due to https://github.com/NixOS/nixpkgs/pull/574152#issuecomment-6203335843
        home.packages = [ inputs'.llm-agents.packages.omp ];
        # TODO: declaratively configure
      };
  };
}
