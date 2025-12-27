{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.git";

  options.programs.git = {
    enable = self.lib.mkDisableOption "git";
  };

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        (pkgs.git-branchless.overrideAttrs (
          let
            src = pkgs.fetchFromGitHub {
              owner = "bitbloxhub";
              repo = "git-branchless";
              rev = "c63070c675242d413ab88969bad5e235b0cc5658";
              hash = "sha256-KzQOXRiboscpzrupi2JlcnBBm4b8+m5fr8NDnEug7CY=";
            };
          in
          {
            inherit src;
            cargoDeps = pkgs.rustPlatform.importCargoLock {
              lockFile = "${src}/Cargo.lock";
            };
            # Current master branch works without patches, see
            # https://github.com/arxanas/git-branchless/issues/1585#issuecomment-3467473525
            postPatch = "";
          }
        ))
      ];

      programs.git.enable = true;
      programs.git.package = pkgs.git.overrideAttrs (old: {
        patches =
          (old.patches or [ ])
          ++ (builtins.map (x: ./git_patches/${x}) (builtins.attrNames (builtins.readDir ./git_patches)));
        doCheck = false;
        doInstallCheck = false;
      });
    };
}
