{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    agent-roam = {
      url = "github:bitbloxhub/agent-roam";
      flake = false;
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    skills-flake = {
      url = "github:bitbloxhub/skills-flake";
      inputs = {
        flake-file.follows = "flake-file";
        crate2nix.follows = "crate2nix";
        fenix.follows = "fenix";
        flake-parts.follows = "flake-parts";
        flint.follows = "flint";
        import-tree.follows = "import-tree";
        make-shell.follows = "make-shell";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.agent-roam-pi-extension = pkgs.stdenv.mkDerivation {
        buildPhase = ''
          runHook preBuild
          tmp="$TMPDIR/agent-roam-pi-extension-out"
          rm -rf "$tmp"
          mkdir -p "$tmp"

          pnpm --config.auto-install-peers=false --config.strict-peer-dependencies=false --filter=agent-roam-pi deploy --legacy --prod --offline "$tmp"

          # Copy to $out with symlink dereference to avoid /build/source/* workspace links.
          cp -aL "$tmp"/. "$out"/

          runHook postBuild
        '';
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.pnpmConfigHook
          pkgs.pnpm_10
        ];
        pname = "agent-roam-pi-extension";
        pnpmDeps = pkgs.fetchPnpmDeps {
          fetcherVersion = 3;
          hash = "sha256-MipjP9qQT/zMJd8Y6/GVJP+5QR4+9eznDr5h30MNqZM=";
          pname = "agent-roam-extension";
          pnpm = pkgs.pnpm_10;
          pnpmWorkspaces = [ "agent-roam-pi" ];
          src = inputs.agent-roam;
          version = inputs.agent-roam.rev;
        };
        pnpmWorkspaces = [ "agent-roam-pi" ];
        pnpm_config_auto_install_peers = "false";
        pnpm_config_manage_package_manager_versions = "false";
        src = inputs.agent-roam;
        version = inputs.agent-roam.rev;
      };
      treefmt.settings.global.excludes = [
        "nix/pi/pi-hashline-edit/package-lock.json"
      ];
    };

  flake.aspects.cli =
    { aspect, ... }:
    {
      includes = [ aspect._.pi ];
      _.pi.homeManager =
        {
          pkgs,
          inputs',
          self',
          ...
        }:
        let
          piCatppuccin = pkgs.fetchzip {
            hash = "sha256-6+4aPGFds6S5VpdWdqfne0mZscHX9nKqNdDlvx+N7lc=";
            stripRoot = false;
            url = "https://registry.npmjs.org/@sherif-fanous/pi-catppuccin/-/pi-catppuccin-0.2.0.tgz";
          };
          piHashlineEdit = pkgs.buildNpmPackage rec {
            dontNpmBuild = true;
            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp -r index.ts src prompts README.md LICENSE node_modules $out/
              runHook postInstall
            '';
            npmDepsHash = "sha256-3LimhPRzJm/EoQmbtGHfLtUMTNh7qRUt6DrPOENutAU=";
            pname = "pi-hashline-edit";
            postPatch = ''
              cp ${./pi-hashline-edit/package-lock.json} package-lock.json
              cp ${./pi-hashline-edit/package.json} package.json
            '';
            src = pkgs.fetchFromGitHub {
              hash = "sha256-ylpq7+rXDk2+c0Lvd73D1rkJ6onHo+1QiCiEbFA8MKY=";
              owner = "RimuruW";
              repo = "pi-hashline-edit";
              rev = "v${version}";
            };
            version = "0.6.0";
          };
        in
        {
          imports = [ inputs.skills-flake.homeModules.default ];
          home = {
            file = {
              ".pi/agent/extensions" = {
                recursive = true;
                source = ./extensions;
              };
              ".pi/agent/extensions/agent-roam" = {
                recursive = true;
                source = self'.packages.agent-roam-pi-extension;
              };
              ".pi/agent/extensions/pi-hashline-edit" = {
                recursive = true;
                source = piHashlineEdit;
              };
              ".pi/agent/settings.json".text = builtins.toJSON {
                defaultModel = "gpt-5.6-luna";
                defaultProvider = "openai-codex";
                defaultThinkingLevel = "medium";
                enableInstallTelemetry = false;
                enabledModels = [
                  "openrouter/z-ai/glm-5"
                  "openrouter/moonshotai/kimi-k2.5"
                  "openrouter/minimax/minimax-m2.7"
                  "openrouter/openai/gpt-oss-120b"
                  "openrouter/mistralai/mistral-small-2603"
                  "openai-codex/gpt-5.6-luna"
                  "openai-codex/gpt-5.6-terra"
                ];
                followUpMode = "all";
                hideThinkingBlock = false;
                steeringMode = "all";
                theme = "catppuccin-mocha";
              };
              ".pi/agent/themes/catppuccin-mocha.json".source =
                piCatppuccin + "/package/themes/catppuccin-mocha.json";
            };
            packages = [
              inputs'.llm-agents.packages.pi
              inputs'.llm-agents.packages.agent-browser
              inputs'.llm-agents.packages.skills
            ];
            persistence."/persistent".directories = [
              ".pi"
              ".agent-browser"
            ];
            skillsFlake = {
              enable = true;
              agents.pi.enable = true;
              skills = {
                inherit (inputs'.skills-flake.packages.skills.github.vercel-labs.agent-browser) agent-browser;
                inherit (inputs'.skills-flake.packages.skills.github.juliusbrussee.caveman) caveman;
                inherit (inputs'.skills-flake.packages.skills.github.openclaw.openclaw) tmux;
                agent-roam = inputs.agent-roam + "/skills/agent-roam";
              };
            };
          };
        };
    };
}
