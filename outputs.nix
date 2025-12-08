inputs@{
  flake-parts,
  treefmt-nix,
  git-hooks,
  actions-nix,
  nix-auto-ci,
  import-tree,
  home-manager,
  nixpkgs,
  ...
}:
flake-parts.lib.mkFlake
  {
    inherit inputs;
  }
  {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    imports = [
      flake-parts.flakeModules.modules
      treefmt-nix.flakeModule
      git-hooks.flakeModule
      actions-nix.flakeModules.default
      nix-auto-ci.flakeModule
      home-manager.flakeModules.home-manager
      {
        options.flake = flake-parts.lib.mkSubmoduleOptions {
          systemConfigs = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.lazyAttrsOf nixpkgs.lib.types.raw;
            default = { };
            description = ''
              Instantiated system-manager configurations.
            '';
          };
        };
      }
      ./ci.nix
      ./treefmt.nix
      ./flake-file.nix
      (import-tree ./lib)
      ((import-tree.filterNot (nixpkgs.lib.hasSuffix "npins/default.nix")) ./modules)
      ((import-tree.filter (nixpkgs.lib.hasSuffix "default.nix")) ./hosts)
    ];
  }
