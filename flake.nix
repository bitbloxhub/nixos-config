{
  description = "system configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "";
    };

    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.git-hooks.follows = "git-hooks";
    };

    nix-auto-ci = {
      url = "github:aigis-llm/nix-auto-ci";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.git-hooks.follows = "git-hooks";
      inputs.actions-nix.follows = "actions-nix";
    };

    import-tree.url = "github:vic/import-tree";

    crane.url = "github:ipetkov/crane";

    catppuccin = {
      url = "github:catppuccin/nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin-userstyles = {
      url = "github:catppuccin/userstyles";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };

    flake-firefox-nightly = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    betterfox-nix = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.import-tree.follows = "import-tree";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-parts.follows = "flake-parts";
      };
    };

    catppuccin-cosmic = {
      url = "github:catppuccin/cosmic-desktop";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      treefmt-nix,
      git-hooks,
      actions-nix,
      nix-auto-ci,
      import-tree,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib.extend (lib: _: { my = import ./lib { inherit inputs lib; }; });
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = { inherit lib; };
      }
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        imports = [
          flake-parts.flakeModules.modules
          treefmt-nix.flakeModule
          git-hooks.flakeModule
          actions-nix.flakeModules.default
          nix-auto-ci.flakeModule
          home-manager.flakeModules.home-manager
          {
            options.flake = flake-parts.lib.mkSubmoduleOptions {
              systemConfigs = lib.mkOption {
                type = lib.types.lazyAttrsOf lib.types.raw;
                default = { };
                description = ''
                  Instantiated system-manager configurations.
                '';
              };
            };
          }
          ./ci.nix
          ./devshell.nix
          ./treefmt.nix
          (import-tree ./modules)
          ((import-tree.filter (lib.hasSuffix "default.nix")) ./hosts)
        ];

        flake = {
          inherit lib;
        };
      };
}
