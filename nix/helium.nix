{
  inputs,
  ...
}:
{
  flake-file.inputs.helium-browser = {
    url = "github:oxcl/nix-flake-helium-browser";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.helium ];
      _.helium.homeManager = {
        imports = [
          inputs.helium-browser.homeModules.default
        ];

        programs.helium.enable = true;
      };
    };
}
