{
  flake.aspects = {
    system._.hostname = hostname: {
      nixos = {
        networking.hostName = hostname;
      };
    };
  };
}
