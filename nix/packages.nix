{
  flake.grove.projectors = {
    host.nixos = _host: { pkgs, ... }: {

      environment.systemPackages = [ pkgs.git ];
    };
    user.homeManager = _user: { inputs', ... }: {
      home.packages = [
        inputs'.system-manager.packages.default
        inputs'.deploy-rs.packages.default
      ];
    };
  };
}
