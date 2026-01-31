{
  inputs,
  ...
}:
{
  flake-file.inputs.make-shell = {
    url = "github:nicknovitski/make-shell";
    inputs.flake-compat.follows = "";
  };

  imports = [
    inputs.make-shell.flakeModules.default
  ];

  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    {
      make-shells.default = {
        name = "nixos-config";
        packages = [
          # Used for pinning some non-flake inputs (e.g. my custom Firefox addons)
          pkgs.npins
          pkgs.nixos-facter
          inputs'.flint.packages.default
          # Spell check
          pkgs.typos
        ];
      };
    };
}
