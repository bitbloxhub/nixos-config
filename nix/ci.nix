{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "";
        gitignore.follows = "gitignore";
        nixpkgs.follows = "nixpkgs";
      };
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-auto-ci = {
      url = "github:aigis-llm/nix-auto-ci";
      inputs = {
        actions-nix.follows = "actions-nix";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  imports = [
    inputs.git-hooks.flakeModule
    inputs.actions-nix.flakeModules.default
    inputs.nix-auto-ci.flakeModule
  ];

  flake.actions-nix = {
    defaults.jobs = {
      runs-on = "ubuntu-latest";
      timeout-minutes = 60;
    };
    workflows.".github/workflows/nix-x86_64-linux.yaml" = inputs.nix-auto-ci.lib.makeNixGithubAction {
      flake = self;
      useLix = true;
    };
  };
}
