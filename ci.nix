{
  lib,
  inputs,
  ...
}:
{
  flake.actions-nix = {
    defaults = {
      jobs = {
        timeout-minutes = 60;
        runs-on = "ubuntu-latest";
      };
    };
    workflows = {
      ".github/workflows/nix-x86_64-linux.yaml" = inputs.nix-auto-ci.lib.makeNixGithubAction {
        flake = inputs.self;
        useLix = true;
      };
    };
  };
}
