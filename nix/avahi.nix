{
  flake.grove.projectors.host.nixos = _host: {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
