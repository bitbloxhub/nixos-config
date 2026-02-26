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
                version = "580.119.02";
                sha256_64bit = "sha256-gCD139PuiK7no4mQ0MPSr+VHUemhcLqerdfqZwE47Nc=";
                sha256_aarch64 = "sha256-eYcYVD5XaNbp4kPue8fa/zUgrt2vHdjn6DQMYDl0uQs=";
                openSha256 = "sha256-l3IQDoopOt0n0+Ig+Ee3AOcFCGJXhbH1Q1nh1TEAHTE=";
                settingsSha256 = "sha256-sI/ly6gNaUw0QZFWWkMbrkSstzf0hvcdSaogTUoTecI=";
                persistencedSha256 = "sha256-j74m3tAYON/q8WLU9Xioo3CkOSXfo1CwGmDx/ot0uUo=";
              }).override
                {
                  libsOnly = true;
                  kernel = null;
                };
            extraPackages = [ pkgs.mesa ];
          };
        };
        homeManager =
          {
            config,
            ...
          }:
          {
            sops = {
              defaultSopsFile = ./secrets/jonahgam.yaml;
              # TODO: configure ssh to use these
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
          nvidia
          (rices._.catppuccin { })
        ];
      };
    };
}
