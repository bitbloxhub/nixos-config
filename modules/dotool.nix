{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.dotool ];
      _.dotool.homeManager =
        {
          pkgs,
          ...
        }:
        {
          home.packages = [
            pkgs.dotool
          ];

          systemd.user.services.dotool = {
            Unit = {
              Description = "dotool daemon for input automation";
              After = [ "graphical-session.target" ];
            };

            Service = {
              ExecStart = "${pkgs.dotool}/bin/dotoold";
              Restart = "on-failure";
            };

            Install.WantedBy = [ "graphical-session.target" ];
          };
        };
    };
}
