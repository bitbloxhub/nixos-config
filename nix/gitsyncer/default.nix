{
  flake.aspects.system =
    { aspect, ... }:
    {
      _.gitsyncer =
        {
          name,
          humanName ? name,
          repo,
          path,
          time ? "*:0/5",
          message,
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
              systemd.user.services."gitsyncer-${name}" = {
                Unit = {
                  Description = "Git syncer for ${humanName}";
                  After = [ "network-online.target" ];
                  Wants = [ "network-online.target" ];
                };

                Service = {
                  Type = "oneshot";
                  ExecStart = "${gitsyncer}/bin/gitsyncer-${name} ${configFile}";
                };
              };

              systemd.user.timers."gitsyncer-${name}" = {
                Unit.Description = "Timer for git syncer ${humanName}";

                Timer = {
                  OnCalendar = time;
                  Unit = "gitsyncer-${name}.service";
                  Persistent = true;
                };

                Install.WantedBy = [ "timers.target" ];
              };
            };
        };
      _.presets._.gitsyncer._.notes = aspect._.gitsyncer {
        name = "notes";
        repo = "https://github.com/bitbloxhub/notes.git";
        path = "~/notes/";
        message = "notes";
      };
    };
}
