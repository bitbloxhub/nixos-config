{
  lib,
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.git = {
      enable = self.lib.mkDisableOption "git";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = lib.mkIf config.my.programs.git.enable [
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

      programs.git.enable = config.my.programs.git.enable;
      programs.git.package = pkgs.git.overrideAttrs (old: {
        patches =
          (old.patches or [ ])
          ++ (builtins.map (x: ./git_patches/${x}) (builtins.attrNames (builtins.readDir ./git_patches)));
        doCheck = false;
        doInstallCheck = false;
      });
    };
}
