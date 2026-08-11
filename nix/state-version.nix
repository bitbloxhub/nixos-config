# Shared state-version defaults.
{
  flake.grove.projectors = {
    host.nixos = _host: {
      system.stateVersion = "23.11";
    };
    user.homeManager = _user: {
      home.stateVersion = "23.11";
    };
  };
}
