{
  flake.grove.projectors.host.nixos = _host: {
    home-manager = {
      useGlobalPkgs = false;
      useUserPackages = true;
    };
    networking = {
      firewall.enable = false;
      networkmanager.enable = true;
    };
  };
}
