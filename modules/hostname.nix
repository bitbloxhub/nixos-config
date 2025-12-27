{
  lib,
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "hostname";

  options.hostname = lib.mkOption {
    type = lib.types.str;
    description = "Hostname for the system";
  };

  nixos.always =
    {
      config,
      ...
    }:
    {
      networking.hostName = config.my.hostname;
    };
}
