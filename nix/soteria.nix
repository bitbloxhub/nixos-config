{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user.options.soteria.enable = self.lib.mkDisableOption "Soteria";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      let
        soteria = pkgs.soteria.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            (pkgs.fetchpatch {
              hash = "sha256-o2+TZKCV1oqMKoESdmg+PA/ws6piPSLLHYVj2oM8AbA=";
              # https://github.com/jacobmichels/soteria/tree/pam-conversation-completeness
              url = "https://github.com/jacobmichels/soteria/compare/b1521b4...b0d9f6e.patch";
            })
          ];
        });
      in
      lib.mkIf user.config.soteria.enable {
        home.packages = [ soteria ];
        systemd.user.services.soteria = {
          Install.WantedBy = [ "graphical-session.target" ];
          Service = {
            ExecStart = lib.getExe soteria;
            Restart = "on-failure";
          };
          Unit = {
            After = [ "graphical-session.target" ];
            Description = "Soteria Polkit authentication agent";
            PartOf = [ "graphical-session.target" ];
          };
        };
      };
  };
}
