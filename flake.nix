# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{

  outputs = inputs: import ./outputs.nix inputs;

  inputs = {
    actions-nix = {
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:nialov/actions.nix";
    };
    ags = {
      inputs = {
        astal.follows = "astal";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:aylur/ags";
    };
    astal = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:aylur/astal";
    };
    betterfox-nix = {
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
      url = "github:HeitorAugustoLN/betterfox-nix";
    };
    catppuccin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:catppuccin/nix/main";
    };
    catppuccin-cosmic = {
      flake = false;
      url = "github:catppuccin/cosmic-desktop";
    };
    catppuccin-userstyles = {
      flake = false;
      url = "github:catppuccin/userstyles";
    };
    cosmic-manager = {
      inputs = {
        flake-parts.follows = "flake-parts";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:HeitorAugustoLN/cosmic-manager";
    };
    crane.url = "github:ipetkov/crane";
    deploy-rs = {
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
      url = "github:serokell/deploy-rs";
    };
    firefox-addons = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    };
    flake-file.url = "github:vic/flake-file";
    flake-firefox-nightly = {
      inputs = {
        flake-compat.follows = "";
        lib-aggregate.follows = "lib-aggregate";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:nix-community/flake-firefox-nightly";
    };
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    flake-utils = {
      inputs.systems.follows = "systems";
      url = "github:numtide/flake-utils";
    };
    flint = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:NotAShelf/flint";
    };
    git-hooks = {
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:cachix/git-hooks.nix";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/master";
    };
    import-tree.url = "github:vic/import-tree";
    lib-aggregate = {
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs-lib.follows = "nixpkgs";
      };
      url = "github:nix-community/lib-aggregate";
    };
    make-shell = {
      inputs.flake-compat.follows = "";
      url = "github:nicknovitski/make-shell";
    };
    niri-flake = {
      inputs = {
        niri-stable.follows = "";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        xwayland-satellite-stable.follows = "";
      };
      url = "github:sodiboo/niri-flake";
    };
    nix-auto-ci = {
      inputs = {
        actions-nix.follows = "actions-nix";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:aigis-llm/nix-auto-ci";
    };
    nix-bwrapper = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nuschtosSearch.follows = "";
        treefmt-nix.follows = "treefmt-nix";
      };
      url = "github:Naxdy/nix-bwrapper";
    };
    nix-system-graphics = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:soupglasses/nix-system-graphics";
    };
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    system-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/system-manager";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
    yazi = {
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:sxyazi/yazi";
    };
  };

}
