{
  lib,
  ...
}:
{
  # From https://github.com/montchr/dotfield/blob/05f9757/src/modules/flake/lib.nix#L6
  options.flake.lib = lib.mkOption {
    description = "Internal helpers library";
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
}
