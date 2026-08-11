{
  lib,
  inputs,
  self,
  ...
}:
let
  pkgs = import inputs.nixpkgs {
    config.allowUnfree = true;
    system = "x86_64-linux";
  };
in
{
  flake = {
    deploy.nodes.extreme-creeper = {
      hostname = "extreme-creeper";
      profilesOrder = [
        "system-manager"
        "home-manager-jonahgam"
      ];
      sshUser = "jonahgam";
    };
    grove = {
      projectors = {
        host.systemManager = _host: {
          imports = [
            inputs.nix-system-graphics.systemModules.default
          ];
          # initramfs patch for bind-mounting /nix
          # Run `sudo update-initramfs -u -k all` after changing
          environment.etc."initramfs-tools/scripts/local-bottom/mount-nix" = {
            mode = "0755";
            text =
              # sh
              ''
                #!/bin/sh
                set -eu

                PREREQ=""

                prereqs() {
                  echo "$PREREQ"
                }

                case "''${1:-}" in
                  prereqs)
                    prereqs
                    exit 0
                    ;;
                esac

                . /scripts/functions

                rootmnt="''${rootmnt:-/root}"

                device="/dev/mapper/crypt-wd-blue-2tb"
                backing="$rootmnt/mnt/wd-blue-2tb"
                nix="$rootmnt/nix"

                [ -b "$device" ] || panic "$device was not unlocked"

                mkdir -p "$backing" "$nix"

                mount -t ext4 \
                  -o noatime,nosuid,nodev,errors=remount-ro \
                  "$device" "$backing" \
                  || panic "failed to mount $device"

                mount -o bind "$backing/nix" "$nix" \
                  || panic "failed to bind-mount /nix"

                mount -o remount,bind,nosuid,nodev "$nix" \
                  || panic "failed to apply /nix bind-mount flags"
              '';
          };
          nixpkgs.hostPlatform = "x86_64-linux";
          system-graphics = {
            enable = true;
            package =
              (pkgs.linuxPackages.nvidiaPackages.mkDriver {
                openSha256 = "sha256-1Q2wuDdZ6KiA/2L3IDN4WXF8t63V/4+JfrFeADI1Cjg=";
                persistencedSha256 = "sha256-ZBfPZyQKW9SkVdJ5cy0cxGap2oc7kyYRDOeM0XyfHfI=";
                settingsSha256 = "sha256-QMx4rUPEGp/8Mc+Bd8UmIet/Qr0GY8bnT/oDN8GAoEI=";
                sha256_64bit = "sha256-p3gbLhwtZcZYCRTHbnntRU0ClF34RxHAMwcKCSqatJ0=";
                sha256_aarch64 = "sha256-pruxWQlLurymRL7PbR24NA6dNowwwX35p6j9mBIDcNs=";
                version = "580.126.18";
              }).override
                {
                  libsOnly = true;
                };
            extraPackages = [ pkgs.mesa ];
          };
          systemd = lib.mkMerge [
            {
              # PAM fix, see https://github.com/Rishabh5321/dotfiles/blob/d71f52b/system-manager/home/README.md?plain=1#L91-L92 and
              # https://github.com/nix-community/home-manager/issues/7027
              paths.pam-unix-chkpwd-wrapper = {
                pathConfig = {
                  PathChanged = "/run/wrappers";
                  PathExists = "/run/wrappers/bin";
                  Unit = "pam-unix-chkpwd-wrapper.service";
                };
                wantedBy = [ "multi-user.target" ];
              };
              services.pam-unix-chkpwd-wrapper = {
                description = "Link host unix_chkpwd into Nix wrapper path";

                serviceConfig = {
                  ExecStart = "/bin/sh -c 'ln -sfn /usr/sbin/unix_chkpwd /run/wrappers/bin/unix_chkpwd'";
                  Type = "oneshot";
                };
              };
            }
            {
              # Similar fix for polkit agents
              paths.polkit-agent-helper-wrapper = {
                pathConfig = {
                  PathChanged = "/run/wrappers";
                  PathExists = "/run/wrappers/bin";
                  Unit = "polkit-agent-helper-wrapper.service";
                };
                wantedBy = [ "multi-user.target" ];
              };
              services.polkit-agent-helper-wrapper = {
                description = "Link host polkit-agent-helper-1 into Nix wrapper path";

                serviceConfig = {
                  ExecStart = "/bin/sh -c 'ln -sfn /usr/lib/polkit-1/polkit-agent-helper-1 /run/wrappers/bin/polkit-agent-helper-1'";
                  Type = "oneshot";
                };
              };
            }
          ];
        };
        user.homeManager =
          _user:
          {
            config,
            ...
          }:
          {
            nixpkgs.config = {
              cudaCapabilities = [ "7.5" ];
              cudaForwardCompat = false;
            };

            sops = {
              defaultSopsFile = ./secrets/jonahgam.yaml;
              secrets = {
                "ssh_keys/github/private".path = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
                "ssh_keys/github/public".path = "${config.home.homeDirectory}/.ssh/id_ed25519_github.pub";
                "ssh_keys/tangled/private".path = "${config.home.homeDirectory}/.ssh/id_ed25519_tangled";
                "ssh_keys/tangled/public".path = "${config.home.homeDirectory}/.ssh/id_ed25519_tangled.pub";
              };
            };
          };
      };
      host.extreme-creeper = {
        hostname = "extreme-creeper";
        nvidia.enable = true;
        users = [ "jonahgam@extreme-creeper" ];
      };
      user."jonahgam@extreme-creeper" = {
        catppuccin.enable = true;
        gitsyncers.notes = {
          message = "notes";
          name = "notes";
          path = "~/notes/";
          repo = "https://github.com/bitbloxhub/notes.git";
        };
        impermanence.enable = true;
        reaper.enable = true;
        renoise.enable = true;
        username = "jonahgam";
      };
    };
    homeConfigurations."jonahgam@extreme-creeper" =
      self.lib.configs.homeManager "x86_64-linux" "jonahgam@extreme-creeper";
    systemConfigs."extreme-creeper" = self.lib.configs.systemManager "x86_64-linux" "extreme-creeper";
  };
}
