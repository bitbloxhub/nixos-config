inputs@{
  flake-parts,
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
      home-manager.flakeModules.home-manager
      ./ci.nix
      ./treefmt.nix
      ./flake-file.nix
      ((import-tree.filterNot (nixpkgs.lib.hasSuffix "npins/default.nix")) ./modules)
      ((import-tree.filter (nixpkgs.lib.hasSuffix "default.nix")) ./hosts)
    ];
  }
