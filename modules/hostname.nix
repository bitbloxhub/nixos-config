{
  lib,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for the system";
    };
  };

  flake.modules.nixos.default =
    {
      config,
      ...
    }:
    {
      networking.hostName = config.my.hostname;
    };
}
