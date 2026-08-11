{
  lib,
  ...
}:
{
  flake.grove = {
    types.host.options.hostname = lib.mkOption {
      type = lib.types.str;
    };
    projectors.host.nixos = host: {
      networking.hostName = host.config.hostname;
    };
  };
}
