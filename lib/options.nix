{
  lib,
  ...
}:
{
  # Lifted from https://github.com/ambroisie/nix-config/blob/66ec807dc6729a8aabd7cb5f42797e246f36befa/lib/options.nix#L6-L9
  # Create an option which is enabled by default, in contrast to
  # `mkEnableOption` ones which are disabled by default.
  flake.lib.mkDisableOption = description: (lib.mkEnableOption description) // { default = true; };
}
