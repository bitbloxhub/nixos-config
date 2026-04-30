{
  inputs,
  ...
}:
{
  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem.treefmt = {
    projectRootFile = "flake.lock";

    settings.global.excludes = [
      "*/npins/*"
      "**/pnpm-lock.yaml"
      "skills-lock.json"
      # Git submodules
      "modules/wezterm/resurrect.wezterm"
      "modules/wezterm/wezterm-types"
    ];
  };
}
