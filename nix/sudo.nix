{
  flake.grove.projectors.host = {
    nixos = _host: {
      security.sudo = {
        enable = true;
        extraConfig = ''
          Defaults:%wheel !env_reset
        '';
        wheelNeedsPassword = false;
      };
    };
    systemManager = _host: {
      security.sudo = {
        enable = true;
        extraConfig = ''
          Defaults:%wheel !env_reset
        '';
        wheelNeedsPassword = false;
      };
    };
  };
}
