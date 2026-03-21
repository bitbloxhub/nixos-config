{
  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.git ];
      _.git.homeManager =
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
                  rev = "ef584f371064d591718f00b51eac8334e110599a";
                  hash = "sha256-3HBVwbchDOj04EU3tHmJj6vupcI1XHcAHwcts50e0WI=";
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

          home.persistence."/persistent".files = [ ".gitconfig" ];
        };
    };
}
