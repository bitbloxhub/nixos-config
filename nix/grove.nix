{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.nix-grove = {
    url = "github:bitbloxhub/nix-grove";
    flake = false;
  };

  imports = [
    (inputs.nix-grove + "/grove.nix")
  ];

  flake.lib.mkDisableOption =
    description:
    (lib.mkEnableOption description)
    // {
      default = true;
    };
}
