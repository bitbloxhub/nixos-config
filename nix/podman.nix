{
  inputs,
  ...
}:
{
  flake-file.inputs.nix-storage-plugin = {
    url = "github:bitbloxhub/nix-storage-plugin";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
      flake-file.follows = "flake-file";
      import-tree.follows = "import-tree";
      make-shell.follows = "make-shell";
      treefmt-nix.follows = "treefmt-nix";
      crate2nix.follows = "crate2nix";
      fenix.follows = "fenix";
      flint.follows = "flint";
      hegel.follows = "";
    };
  };

  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.podman ];
      _.podman =
        let
          port = 59447;
          mountPath = "/run/nix-storage-plugin/layer-store";
        in
        {
          nixos = {
            imports = [
              inputs.nix-storage-plugin.nixosModules.default
            ];

            nixpkgs.overlays = [
              inputs.nix-storage-plugin.overlays.default
            ];
            services.nix-storage-plugin.enable = true;
            services.nix-storage-plugin.port = port;

            programs.fuse.userAllowOther = true;

            virtualisation = {
              containers.enable = true;
              podman = {
                enable = true;
                dockerCompat = true;
              };
            };

            environment.persistence."/persistent" = {
              directories = [
                "/var/lib/containers/storage"
              ];
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
                    prefix = "nix:0";
                    location = "127.0.0.1:${toString port}";
                    insecure = true;
                  }
                  {
                    prefix = "flake-github:0";
                    location = "127.0.0.1:${toString port}/flake-github";
                    insecure = true;
                  }
                  {
                    prefix = "flake-tarball-https:0";
                    location = "127.0.0.1:${toString port}/flake-tarball-https";
                    insecure = true;
                  }
                  {
                    prefix = "flake-tarball-http:0";
                    location = "127.0.0.1:${toString port}/flake-tarball-http";
                    insecure = true;
                  }
                  {
                    prefix = "flake-git-https:0";
                    location = "127.0.0.1:${toString port}/flake-git-https";
                    insecure = true;
                  }
                  {
                    prefix = "flake-git-http:0";
                    location = "127.0.0.1:${toString port}/flake-git-http";
                    insecure = true;
                  }
                  {
                    prefix = "flake-git-ssh:0";
                    location = "127.0.0.1:${toString port}/flake-git-ssh";
                    insecure = true;
                  }
                ];
              };
            in
            {
              nixpkgs.overlays = [
                inputs.nix-storage-plugin.overlays.default
              ];

              environment.systemPackages = [
                pkgs.podman
                inputs'.nix-storage-plugin.packages.default
              ];

              environment.etc."containers/storage.conf".text = ''
                [storage.options]
                additionallayerstores = ["${mountPath}:ref"]
              '';

              environment.etc."fuse.conf".text = ''
                user_allow_other
              '';

              environment.etc."containers/registries.conf.d/90-nix-storage-plugin.conf".source = registriesToml;

              systemd.services.nix-storage-plugin-als = {
                description = "nix-storage-plugin Additional Layer Store";
                wantedBy = [ "multi-user.target" ];
                before = [ "crio.service" ];
                path = [ pkgs.fuse3 ];
                serviceConfig = {
                  Type = "simple";
                  RuntimeDirectory = "nix-storage-plugin";
                  RuntimeDirectoryMode = "0755";
                  ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPath}";
                  ExecStart = "${inputs'.nix-storage-plugin.packages.default}/bin/nix-storage-plugin mount-store --mount-path ${mountPath}";
                  Restart = "on-failure";
                  RestartSec = 1;
                  PrivateMounts = false;
                  Environment = [ "RUST_LOG=debug" ];
                };
              };

              systemd.services.nix-storage-plugin-registry = {
                description = "nix-storage-plugin registry adapter";
                wantedBy = [ "multi-user.target" ];
                path = [ pkgs.lix ];
                serviceConfig = {
                  Type = "simple";
                  ExecStart = "${inputs'.nix-storage-plugin.packages.default}/bin/nix-storage-plugin serve-image --bind 127.0.0.1:${toString port}";
                  Restart = "on-failure";
                  RestartSec = 1;
                  Environment = [ "RUST_LOG=debug" ];
                };
              };
            };

          homeManager =
            {
              pkgs,
              inputs',
              ...
            }:
            {
              nixpkgs.overlays = [
                inputs.nix-storage-plugin.overlays.default
              ];

              home.packages = [
                pkgs.podman
                inputs'.nix-storage-plugin.packages.default
              ];

              xdg.configFile."containers/storage.conf".text = ''
                [storage]
                driver = "overlay"

                [storage.options]
                additionallayerstores = ["${mountPath}:ref"]
              '';

              home.persistence."/persistent".directories = [
                ".local/share/containers/storage"
              ];
            };
        };
    };
}
