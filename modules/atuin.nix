{
  bitbloxhub.atuin.homeManager = {
    programs.atuin = {
      enable = true;
      enableNushellIntegration = true;
      flags = [ "--disable-up-arrow" ];
    };
  };
}
