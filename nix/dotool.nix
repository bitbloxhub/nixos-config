{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.dotool.enable = self.lib.mkDisableOption "dotool";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.dotool.enable {
        home.packages = [ pkgs.dotool ];

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
