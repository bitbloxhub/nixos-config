{
  # flake-file.inputs.git-branchless = {
  #   # My fork with many changes. See https://github.com/bitbloxhub/git-branchless/tree/megamerge for more info.
  #   url = "github:bitbloxhub/git-branchless";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };

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
          defaultEmail = "45184892+bitbloxhub@users.noreply.github.com";
          defaultName = "bitbloxhub";
          identities = {
            github = {
              email = "45184892+bitbloxhub@users.noreply.github.com";
              name = "bitbloxhub";
            };
            tangled = {
              email = "did:plc:opkzqnnibclv3nt7rcksgj3p";
              name = "bitbloxhub";
            };
          };
        in
        {
          home.packages = [
            # inputs'.git-branchless.packages.default
            pkgs.git-branchless
          ];
          programs = {
            delta = {
              enable = true;
              enableGitIntegration = true;
              enableJujutsuIntegration = true;
              options = {
                dark = true;
                navigate = true;
                tabs = 4;
              };
            };
            git = {
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
              enable = true;
              # Need to rebase these, but use jujutsu now for new projects and try to adopt it on old ones,
              # so does not really matter, plus my git-branchless fork does not have that much changeid integration either.
              # package = pkgs.git.overrideAttrs (old: {
              #   patches =
              #     (old.patches or [ ])
              #     ++ (builtins.map (x: ./git_patches/${x}) (builtins.attrNames (builtins.readDir ./git_patches)));
              #   doCheck = false;
              #   doInstallCheck = false;
              # });
              settings = {
                alias.pf = "push --force-with-lease --force-if-includes";
                branchless.core.mainBranch = "main";
                core.editor = "nvim";
                credential.helper = "cache --timeout=3600";
                init.defaultBranch = "main";
                merge.conflictstyle = "zdiff3";
                push.autoSetupRemote = true;
                rebase.updateRefs = true;
                rerere = {
                  autoupdate = true;
                  enabled = true;
                };
                url."ssh://git@github.com/".insteadOf = "https://github.com/";
                user = {
                  email = defaultEmail;
                  name = defaultName;
                };
              };
              lfs.enable = true;
            };
            # Have to keep this in here at least until https://github.com/jj-vcs/jj/issues/4048 is implemented
            jujutsu = {
              enable = true;
              settings = {
                ui.editor = "nvim";
                # Just use github as default, have to manually set per-repo for tangled due to https://github.com/jj-vcs/jj/issues/6028
                user = {
                  email = defaultEmail;
                  name = defaultName;
                };
              };
            };
          };
        };
    };
}
