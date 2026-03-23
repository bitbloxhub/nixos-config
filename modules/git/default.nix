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
        let
          defaultName = "bitbloxhub";
          defaultEmail = "45184892+bitbloxhub@users.noreply.github.com";

          identities = {
            github = {
              name = "bitbloxhub";
              email = "45184892+bitbloxhub@users.noreply.github.com";
            };
            tangled = {
              name = "bitbloxhub";
              email = "did:plc:opkzqnnibclv3nt7rcksgj3p";
            };
          };
        in
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

          programs.delta = {
            enable = true;
            enableGitIntegration = true;
            options = {
              navigate = true;
              dark = true;
              tabs = 4;
            };
          };

          programs.git = {
            enable = true;
            lfs.enable = true;
            package = pkgs.git.overrideAttrs (old: {
              patches =
                (old.patches or [ ])
                ++ (builtins.map (x: ./git_patches/${x}) (builtins.attrNames (builtins.readDir ./git_patches)));
              doCheck = false;
              doInstallCheck = false;
            });
            settings = {
              user = {
                name = defaultName;
                email = defaultEmail;
              };

              credential.helper = "store";
              core.editor = "nvim";
              init.defaultBranch = "main";
              branchless.core.mainBranch = "main";

              push.autoSetupRemote = true;
              rebase.updateRefs = true;

              alias.pf = "push --force-with-lease --force-if-includes";

              merge.conflictstyle = "diff3";

              url = {
                "ssh://git@github.com/" = {
                  insteadOf = "https://github.com/";
                };
              };
            };
            includes = [
              # github (ssh)
              {
                condition = "hasconfig:remote.*.url:git@github.com:*/**";
                contents.user = identities.github;
              }
              # github (https)
              {
                condition = "hasconfig:remote.*.url:https://github.com/**";
                contents.user = identities.github;
              }
              # tangled (ssh)
              {
                condition = "hasconfig:remote.*.url:git@tangled.sh:*/**";
                contents.user = identities.tangled;
              }
              # tangled (https)
              {
                condition = "hasconfig:remote.*.url:https://tangled.sh/**";
                contents.user = identities.tangled;
              }
            ];
          };

          home.persistence."/persistent".files = [ ".gitconfig" ];
        };
    };
}
