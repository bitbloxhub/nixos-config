{
  lib,
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "nix-system-graphics";

  flake-file.inputs.nix-system-graphics = {
    url = "github:soupglasses/nix-system-graphics";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  options.nix-system-graphics = {
    enable = lib.mkEnableOption "nix-system-graphics";
    driver = lib.mkOption { type = lib.types.package; };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };

  systemManager.ifEnabled =
    {
      config,
      ...
    }:
    {
      imports = [
        inputs.nix-system-graphics.systemModules.default
      ];

      system-graphics = {
        enable = true;
        package = config.my.nix-system-graphics.driver;
        inherit (config.my.nix-system-graphics) extraPackages;
      };
    };
}
