{
  lib,
  inputs,
  self,
  ...
}:

{
  flake-file.inputs.helium-browser = {
    url = "github:oxcl/nix-flake-helium-browser";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.grove = {
    types.user.options.helium.enable = self.lib.mkDisableOption "Helium";
    projectors.user.homeManager = user: {
      imports = [ inputs.helium-browser.homeModules.default ];
      config = lib.mkIf user.config.helium.enable {
        programs.helium.enable = true;
      };
    };
  };
}
