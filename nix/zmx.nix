{
  flake-file.inputs.zmx = {
    url = "github:neurosnap/zmx";
    inputs.zig2nix.inputs.nixpkgs.follows = "nixpkgs";
    inputs.zig2nix.inputs.flake-utils.follows = "flake-utils";
  };

  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.zmx ];
      _.zmx.homeManager =
        {
          inputs',
          ...
        }:
        {
          home.packages = [
            inputs'.zmx.packages.zmx
          ];
        };
    };
}
