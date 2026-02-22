{
  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.podman ];
      _.podman.nixos = {
        virtualisation = {
          containers.enable = true;
          podman = {
            enable = true;
            dockerCompat = true;
          };
        };
      };
    };
}
