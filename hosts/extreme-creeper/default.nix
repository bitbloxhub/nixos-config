{
  inputs,
  self,
  ...
}:
let
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  flake.systemConfigs."extreme-creeper" =
    self.lib.configs.systemManager "x86_64-linux" "host_extreme-creeper";
  flake.homeConfigurations."jonahgam@extreme-creeper" =
    self.lib.configs.homeManager "x86_64-linux" "host_extreme-creeper";

  flake.deploy.nodes.extreme-creeper = {
    hostname = "extreme-creeper";
    sshUser = "jonahgam";
    interactiveSudo = true;
    profilesOrder = [
      "system-manager"
      "home-manager-jonahgam"
    ];
    profiles = {
      home-manager-jonahgam.interactiveSudo = false;
    };
  };

  flake.aspects =
    { aspects, ... }:
    {
      host_extreme-creeper = {
        systemManager = {
          imports = [
            inputs.nix-system-graphics.systemModules.default
          ];

          nixpkgs.hostPlatform = "x86_64-linux";

          system-graphics = {
            enable = true;
            package =
              (pkgs.linuxPackages.nvidiaPackages.mkDriver {
                version = "580.126.18";
                sha256_64bit = "sha256-p3gbLhwtZcZYCRTHbnntRU0ClF34RxHAMwcKCSqatJ0=";
                sha256_aarch64 = "sha256-pruxWQlLurymRL7PbR24NA6dNowwwX35p6j9mBIDcNs=";
                openSha256 = "sha256-1Q2wuDdZ6KiA/2L3IDN4WXF8t63V/4+JfrFeADI1Cjg=";
                settingsSha256 = "sha256-QMx4rUPEGp/8Mc+Bd8UmIet/Qr0GY8bnT/oDN8GAoEI=";
                persistencedSha256 = "sha256-ZBfPZyQKW9SkVdJ5cy0cxGap2oc7kyYRDOeM0XyfHfI=";
              }).override
                {
                  libsOnly = true;
                  kernel = null;
                };
            extraPackages = [ pkgs.mesa ];
          };

          # PAM fix, see https://github.com/Rishabh5321/dotfiles/blob/d71f52b/system-manager/home/README.md?plain=1#L91-L92 and
          # https://github.com/nix-community/home-manager/issues/7027
          systemd.tmpfiles.rules = [
            "d    /run/wrappers/bin        0755 root root -   -"
            "L+   /run/wrappers/bin/unix_chkpwd -    -    -   -   /usr/sbin/unix_chkpwd"
          ];
        };
        homeManager =
          {
            config,
            ...
          }:
          {
            sops = {
              defaultSopsFile = ./secrets/jonahgam.yaml;
              secrets."ssh_keys/github/private" = {
                path = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
              };
              secrets."ssh_keys/github/public" = {
                path = "${config.home.homeDirectory}/.ssh/id_ed25519_github.pub";
              };
              secrets."ssh_keys/tangled/private" = {
                path = "${config.home.homeDirectory}/.ssh/id_ed25519_tangled";
              };
              secrets."ssh_keys/tangled/public" = {
                path = "${config.home.homeDirectory}/.ssh/id_ed25519_tangled.pub";
              };
            };
          };
        includes = with aspects; [
          system
          (system._.user {
            username = "jonahgam";
            aspect = " host_extreme-creeper";
          })
          cli
          gui
          editors
          gaming
          daw
          nvidia
          (rices._.catppuccin { })
        ];
      };
    };
}
