{
  lib,
  ...
}:
let
  extra-substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://cache.nixos-cuda.org"
    "https://catppuccin.cachix.org"
    "https://cache.lix.systems"
    "https://niri.cachix.org"
    "https://ags.cachix.org"
    "https://yazi.cachix.org"
  ];
  extra-trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    "ags.cachix.org-1:naAvMrz0CuYqeyGNyLgE010iUiuf/qx6kYrUv3NwAJ8="
    "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
  ];
in
{
  flake-file.nixConfig = {
    inherit extra-substituters extra-trusted-public-keys;
  };

  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.nix ];
      _.nix.nixos =
        {
          pkgs,
          ...
        }:
        {
          nix = {
            enable = true;
            package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
            settings = {
              experimental-features = [
                "nix-command"
                "flakes"
              ];
              inherit extra-substituters extra-trusted-public-keys;
            };
          };
        };
    };
}
