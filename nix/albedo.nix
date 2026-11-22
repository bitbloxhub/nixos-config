{
  lib,
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.albedo = {
    url = "git+https://tangled.org/okami.mom/albedo";
    inputs = {
      flake-parts.follows = "flake-parts";
      import-tree.follows = "import-tree";
      nixpkgs.follows = "nixpkgs";
      tg.follows = ""; # devShell-only input
      treefmt-nix.follows = "treefmt-nix";
      # pyproject-nix.follows = "pyproject-nix";
      # uv2nix.follows = "uv2nix";
      # pyproject-build-systems.follows = "pyproject-build-systems";
    };
  };

  flake.grove = {
    types.user.options.albedo.enable = self.lib.mkDisableOption "Albedo";
    projectors.user.homeManager = user: {
      imports = [ inputs.albedo.homeModules.default ];
      config = lib.mkIf user.config.albedo.enable {
        programs.albedo.enable = true;
        services.albedo = {
          enable = true;
          web = {
            enable = true;
            allowedNetworks = [ ];
            port = 26686;
          };
        };
        # Inherit PATH from the user systemd manager, not the upstream service default.
        systemd.user.services.albedo.Service.Environment = lib.mkForce [
          "ALBEDO_HOME=%h/.albedo"
        ];
      };
    };
  };
}
