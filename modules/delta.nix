{
  bitbloxhub.delta.homeManager =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.delta
      ];
    };
}
