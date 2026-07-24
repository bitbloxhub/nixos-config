{
  inputs,
  ...
}:
{
  flake-file.inputs.nix-storage-plugin = {
    url = "github:bitbloxhub/nix-storage-plugin";
    inputs = {
      flake-file.follows = "flake-file";
      crate2nix.follows = "crate2nix";
      fenix.follows = "fenix";
      flake-parts.follows = "flake-parts";
      flint.follows = "flint";
      hegel.follows = "";
      import-tree.follows = "import-tree";
      make-shell.follows = "make-shell";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
    };
  };

  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.podman ];
      _.podman =
        let
          mountPath = "/run/nix-storage-plugin/layer-store";
          port = 59447;
        in
        {
          homeManager =
            {
              pkgs,
              inputs',
              ...
            }:
            {
              home = {
                packages = [
                  pkgs.podman
                  inputs'.nix-storage-plugin.packages.default
                ];
                persistence."/persistent".directories = [
                  ".local/share/containers/storage"
                ];
              };
              nixpkgs.overlays = [
                inputs.nix-storage-plugin.overlays.default
              ];
              xdg.configFile."containers/storage.conf".text = ''
                [storage]
                driver = "overlay"

                [storage.options]
                additionallayerstores = ["${mountPath}:ref"]
              '';
            };
          nixos = {
            imports = [
              inputs.nix-storage-plugin.nixosModules.default
            ];
            environment.persistence."/persistent".directories = [
              "/var/lib/containers/storage"
            ];
            nixpkgs.overlays = [
              inputs.nix-storage-plugin.overlays.default
            ];
            programs.fuse.userAllowOther = true;
            services.nix-storage-plugin = {
              inherit port;
              enable = true;
            };
            virtualisation = {
              containers.enable = true;
              podman = {
                enable = true;
                dockerCompat = true;
              };
            };
          };
          systemManager =
            {
              pkgs,
              inputs',
              ...
            }:
            let
              registriesToml = (pkgs.formats.toml { }).generate "90-nix-storage-plugin.conf" {
                registry = [
                  {
                    insecure = true;
                    location = "127.0.0.1:${toString port}";
                    prefix = "nix:0";
                  }
                  {
                    insecure = true;
                    location = "127.0.0.1:${toString port}/flake-github";
                    prefix = "flake-github:0";
                  }
                  {
                    insecure = true;
                    location = "127.0.0.1:${toString port}/flake-tarball-https";
                    prefix = "flake-tarball-https:0";
                  }
                  {
                    insecure = true;
                    location = "127.0.0.1:${toString port}/flake-tarball-http";
                    prefix = "flake-tarball-http:0";
                  }
                  {
                    insecure = true;
                    location = "127.0.0.1:${toString port}/flake-git-https";
                    prefix = "flake-git-https:0";
                  }
                  {
                    insecure = true;
                    location = "127.0.0.1:${toString port}/flake-git-http";
                    prefix = "flake-git-http:0";
                  }
                  {
                    insecure = true;
                    location = "127.0.0.1:${toString port}/flake-git-ssh";
                    prefix = "flake-git-ssh:0";
                  }
                ];
              };
            in
            {
              environment = {
                etc = {
                  "containers/registries.conf.d/90-nix-storage-plugin.conf".source = registriesToml;
                  "containers/storage.conf".text = ''
                    [storage.options]
                    additionallayerstores = ["${mountPath}:ref"]
                  '';
                  "fuse.conf".text = ''
                    user_allow_other
                  '';
                };
                systemPackages = [
                  pkgs.podman
                  inputs'.nix-storage-plugin.packages.default
                ];
              };
              nixpkgs.overlays = [
                inputs.nix-storage-plugin.overlays.default
              ];
              systemd.services = {
                nix-storage-plugin-als = {
                  before = [ "crio.service" ];
                  description = "nix-storage-plugin Additional Layer Store";
                  path = [ pkgs.fuse3 ];
                  serviceConfig = {
                    Environment = [ "RUST_LOG=debug" ];
                    ExecStart = "${inputs'.nix-storage-plugin.packages.default}/bin/nix-storage-plugin mount-store --mount-path ${mountPath}";
                    ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPath}";
                    PrivateMounts = false;
                    Restart = "on-failure";
                    RestartSec = 1;
                    RuntimeDirectory = "nix-storage-plugin";
                    RuntimeDirectoryMode = "0755";
                    Type = "simple";
                  };
                  wantedBy = [ "multi-user.target" ];
                };
                nix-storage-plugin-registry = {
                  description = "nix-storage-plugin registry adapter";
                  path = [ pkgs.lix ];
                  serviceConfig = {
                    Environment = [ "RUST_LOG=debug" ];
                    ExecStart = "${inputs'.nix-storage-plugin.packages.default}/bin/nix-storage-plugin serve-image --bind 127.0.0.1:${toString port}";
                    Restart = "on-failure";
                    RestartSec = 1;
                    Type = "simple";
                  };
                  wantedBy = [ "multi-user.target" ];
                };
              };
            };
        };
    };
}
