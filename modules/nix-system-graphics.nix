{ lib, ... }:
{
  flake.modules.generic.default = {
    options.my.nix-system-graphics = {
      enable = lib.mkEnableOption "nix-system-graphics";
      driver = lib.mkOption { type = lib.types.package; };
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
    };
  };

  flake.modules.systemManager.default =
    { config, ... }:
    {
      system-graphics = {
        inherit (config.my.nix-system-graphics) enable;
        package = config.my.nix-system-graphics.driver;
        inherit (config.my.nix-system-graphics) extraPackages;
      };
    };
}
