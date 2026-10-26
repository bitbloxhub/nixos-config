{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user =
      { config, ... }:
      {
        config = lib.mkIf config.codex.enable {
          unfree.packages = [ "chatgpt" ];
        };
        options.codex.enable = self.lib.mkDisableOption "Codex (and ChatGPT desktop app)";
      };
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.codex.enable {
        home.packages = [
          pkgs.codex
          pkgs.chatgpt
        ];
        # TODO: declaratively configure
      };
  };
}
