{
  lib,
  self,
  ...
}:
{
  flake-file.inputs.albedo = {
    url = "git+https://tangled.org/okami.mom/albedo";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      tg.follows = ""; # devShell-only input
      treefmt-nix.follows = "treefmt-nix";
    };
  };

  flake.grove = {
    types.user.options.albedo.enable = self.lib.mkDisableOption "Albedo";
    projectors.user.homeManager =
      user:
      {
        inputs',
        ...
      }:
      lib.mkIf user.config.albedo.enable {
        home.packages = [ inputs'.albedo.packages.default ];
        systemd.user.services.albedo = {
          Install.WantedBy = [ "default.target" ];
          Service = {
            ExecStart = "${lib.getExe inputs'.albedo.packages.default} web --foreground --local --port 26686 --no-open";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Unit = {
            After = [ "network.target" ];
            Description = "Albedo daemon and web UI";
          };
        };
      };
  };
}
