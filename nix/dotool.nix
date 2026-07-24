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
            Install.WantedBy = [ "graphical-session.target" ];
            Service = {
              ExecStart = "${pkgs.dotool}/bin/dotoold";
              Restart = "on-failure";
            };
            Unit = {
              After = [ "graphical-session.target" ];
              Description = "dotool daemon for input automation";
            };
          };
        };
    };
}
