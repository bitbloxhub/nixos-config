{
  flake.aspects.system =
    { aspect, ... }:
    {
      _ = {
        gitsyncer =
          {
            message,
            name,
            path,
            repo,
            humanName ? name,
            time ? "*:0/5",
          }:
          {
            homeManager =
              {
                pkgs,
                ...
              }:
              let
                configFile = pkgs.writeText "gitsyncer-${name}.json" (
                  builtins.toJSON {
                    inherit
                      humanName
                      repo
                      path
                      message
                      ;
                  }
                );

                gitsyncer = pkgs.writers.writeNuBin "gitsyncer-${name}" ''
                  ${builtins.readFile ./gitsyncer.nu}
                '';
              in
              {
                systemd.user = {
                  services."gitsyncer-${name}" = {
                    Service = {
                      ExecStart = "${gitsyncer}/bin/gitsyncer-${name} ${configFile}";
                      Type = "oneshot";
                    };
                    Unit = {
                      After = [ "network-online.target" ];
                      Description = "Git syncer for ${humanName}";
                      Wants = [ "network-online.target" ];
                    };
                  };
                  timers."gitsyncer-${name}" = {
                    Install.WantedBy = [ "timers.target" ];
                    Timer = {
                      OnCalendar = time;
                      Persistent = true;
                      Unit = "gitsyncer-${name}.service";
                    };
                    Unit.Description = "Timer for git syncer ${humanName}";
                  };
                };
              };
          };
        presets._.gitsyncer._.notes = aspect._.gitsyncer {
          message = "notes";
          name = "notes";
          path = "~/notes/";
          repo = "https://github.com/bitbloxhub/notes.git";
        };
      };
    };
}
