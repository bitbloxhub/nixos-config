{
  lib,
  ...
}:
{
  flake.grove = {
    types.user =
      {
        lib,
        ...
      }:
      {
        options.gitsyncers = lib.mkOption {
          default = { };
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                humanName = lib.mkOption {
                  default = null;
                  type = lib.types.nullOr lib.types.str;
                };
                message = lib.mkOption { type = lib.types.str; };
                name = lib.mkOption { type = lib.types.str; };
                path = lib.mkOption { type = lib.types.str; };
                repo = lib.mkOption { type = lib.types.str; };
                time = lib.mkOption {
                  default = "*:0/5";
                  type = lib.types.str;
                };
              };
            }
          );
        };
      };
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      let
        gitsyncer = pkgs.writers.writeNuBin "gitsyncer" ''
          ${builtins.readFile ./gitsyncer.nu}
        '';
        mkSyncerConfig =
          id: cfg:
          pkgs.writeText "gitsyncer-${id}.json" (
            builtins.toJSON {
              inherit (cfg) repo path message;
              humanName = if cfg.humanName == null then cfg.name else cfg.humanName;
            }
          );
        syncers = user.config.gitsyncers;
      in
      {
        systemd.user = {
          services = lib.mapAttrs' (
            id: cfg:
            let
              humanName = if cfg.humanName == null then cfg.name else cfg.humanName;
            in
            {
              name = "gitsyncer-${id}";
              value = {
                Service = {
                  ExecStart = "${gitsyncer}/bin/gitsyncer ${mkSyncerConfig id cfg}";
                  Type = "oneshot";
                };
                Unit = {
                  After = [ "network-online.target" ];
                  Description = "Git syncer for ${humanName}";
                  Wants = [ "network-online.target" ];
                };
              };
            }
          ) syncers;
          timers = lib.mapAttrs' (
            id: cfg:
            let
              humanName = if cfg.humanName == null then cfg.name else cfg.humanName;
            in
            {
              name = "gitsyncer-${id}";
              value = {
                Install.WantedBy = [ "timers.target" ];
                Timer = {
                  OnCalendar = cfg.time;
                  Persistent = true;
                  Unit = "gitsyncer-${id}.service";
                };
                Unit.Description = "Timer for git syncer ${humanName}";
              };
            }
          ) syncers;
        };
      };
  };
}
