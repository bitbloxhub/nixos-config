{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
        flake-parts.follows = "flake-parts";
      };
    };

    skills-flake = {
      url = "github:bitbloxhub/skills-flake";
      inputs = {
        flake-file.follows = "flake-file";
        treefmt-nix.follows = "treefmt-nix";
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        flint.follows = "flint";
        make-shell.follows = "make-shell";
        crate2nix.follows = "crate2nix";
        fenix.follows = "fenix";
      };
    };

    agent-roam = {
      url = "github:bitbloxhub/agent-roam";
      flake = false;
    };
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      treefmt.settings.global.excludes = [
        "nix/pi/pi-hashline-edit/package-lock.json"
      ];

      packages.agent-roam-pi-extension = pkgs.stdenv.mkDerivation {
        pname = "agent-roam-pi-extension";
        version = inputs.agent-roam.rev;
        src = inputs.agent-roam;

        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.pnpmConfigHook
          pkgs.pnpm_10
        ];

        pnpm_config_manage_package_manager_versions = "false";
        pnpm_config_auto_install_peers = "false";
        pnpmWorkspaces = [ "agent-roam-pi" ];
        pnpmDeps = pkgs.fetchPnpmDeps {
          pname = "agent-roam-extension";
          version = inputs.agent-roam.rev;
          src = inputs.agent-roam;
          pnpmWorkspaces = [ "agent-roam-pi" ];
          pnpm = pkgs.pnpm_10;
          fetcherVersion = 3;
          hash = "sha256-MipjP9qQT/zMJd8Y6/GVJP+5QR4+9eznDr5h30MNqZM=";
        };

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
      };
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
          piHashlineEdit = pkgs.buildNpmPackage rec {
            pname = "pi-hashline-edit";
            version = "0.6.0";

            src = pkgs.fetchFromGitHub {
              owner = "RimuruW";
              repo = "pi-hashline-edit";
              rev = "v${version}";
              hash = "sha256-ylpq7+rXDk2+c0Lvd73D1rkJ6onHo+1QiCiEbFA8MKY=";
            };

            postPatch = ''
              cp ${./pi-hashline-edit/package-lock.json} package-lock.json
              cp ${./pi-hashline-edit/package.json} package.json
            '';

            npmDepsHash = "sha256-3LimhPRzJm/EoQmbtGHfLtUMTNh7qRUt6DrPOENutAU=";
            dontNpmBuild = true;

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp -r index.ts src prompts README.md LICENSE node_modules $out/
              runHook postInstall
            '';
          };

          piCatppuccin = pkgs.fetchzip {
            url = "https://registry.npmjs.org/@sherif-fanous/pi-catppuccin/-/pi-catppuccin-0.2.0.tgz";
            hash = "sha256-6+4aPGFds6S5VpdWdqfne0mZscHX9nKqNdDlvx+N7lc=";
            stripRoot = false;
          };
        in
        {
          imports = [ inputs.skills-flake.homeModules.default ];

          home.packages = [
            inputs'.llm-agents.packages.pi
            inputs'.llm-agents.packages.agent-browser
            inputs'.llm-agents.packages.skills
          ];

          home.file.".pi/agent/settings.json".text = builtins.toJSON {
            defaultProvider = "openai-codex";
            defaultModel = "gpt-5.3-codex";
            hideThinkingBlock = false;
            defaultThinkingLevel = "medium";
            enabledModels = [
              "openrouter/z-ai/glm-5"
              "openrouter/moonshotai/kimi-k2.5"
              "openrouter/minimax/minimax-m2.7"
              "openrouter/openai/gpt-oss-120b"
              "openrouter/mistralai/mistral-small-2603"
              "openai-codex/gpt-5.3-codex"
              "openai-codex/gpt-5.4"
            ];
            steeringMode = "all";
            followUpMode = "all";
            enableInstallTelemetry = false;
            theme = "catppuccin-mocha";
          };

          home.file.".pi/agent/extensions" = {
            source = ./extensions;
            recursive = true;
          };

          home.file.".pi/agent/extensions/pi-hashline-edit" = {
            source = piHashlineEdit;
            recursive = true;
          };

          home.file.".pi/agent/extensions/agent-roam" = {
            source = self'.packages.agent-roam-pi-extension;
            recursive = true;
          };

          home.file.".pi/agent/themes/catppuccin-mocha.json".source =
            piCatppuccin + "/package/themes/catppuccin-mocha.json";

          home.skillsFlake = {
            enable = true;
            agents.pi.enable = true;
            skills = {
              inherit (inputs'.skills-flake.packages.skills.github.vercel-labs.agent-browser) agent-browser;
              inherit (inputs'.skills-flake.packages.skills.github.juliusbrussee.caveman) caveman;
              inherit (inputs'.skills-flake.packages.skills.github.openclaw.openclaw) tmux;
              agent-roam = inputs.agent-roam + "/skills/agent-roam";
            };
          };

          home.persistence."/persistent".directories = [
            ".pi"
            ".agent-browser"
          ];
        };
    };
}
