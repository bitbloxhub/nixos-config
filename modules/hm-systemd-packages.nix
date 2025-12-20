{
  # From https://github.com/nix-community/home-manager/issues/4922#issuecomment-3618435885
  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.systemd;
    in
    {

      options.systemd = {
        packages = lib.mkOption {
          type = with lib.types; types.listOf types.package;
          default = [ ];
          description = ''
            Files in «pkg»/share/systemd/user will be included in the user's
            $XDG_CONFIG_HOME/systemd/user directory.
          '';
        };
      };

      config = {
        xdg.configFile."systemd/user" = {
          recursive = true;
          source = pkgs.symlinkJoin {
            name = "user-systemd-units";
            paths = cfg.packages;
            stripPrefix = "/share/systemd/user";
          };
        };
      };
    };
}
