{
  lib,
  inputs,
  ...
}:
let
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://cache.nixos-cuda.org"
    "https://catppuccin.cachix.org"
    "https://cache.lix.systems"
    "https://niri.cachix.org"
    "https://yazi.cachix.org"
    "https://vicinae.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
    "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
  ];
in
{
  flake-file = {
    inputs.pedantix = {
      url = "github:Swarsel/pedantix";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks-nix.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nixConfig = {
      inherit substituters trusted-public-keys;
    };
  };

  imports = [
    inputs.pedantix.flakeModules.default
  ];

  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    {
      make-shells.default.packages = [
        pkgs.nixfmt
        pkgs.deadnix
        pkgs.statix
        inputs'.pedantix.packages.pedantix
      ];

      treefmt.programs = {
        deadnix.enable = true;
        nixfmt.enable = true;
        pedantix = {
          enable = true;
          excludes = [ "flake.nix" ];
        };
        statix.enable = true;
      };
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
              inherit substituters trusted-public-keys;
              experimental-features = [
                "nix-command"
                "flakes"
              ];
              trusted-users = [
                "root"
                "@wheel"
              ];
            };
          };
        };
    };
}
