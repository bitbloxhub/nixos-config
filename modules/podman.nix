{
  flake.aspects.system =
    { aspect, ... }:
    {
      includes = [ aspect._.podman ];
      _.podman = {
        nixos = {
          virtualisation = {
            containers.enable = true;
            podman = {
              enable = true;
              dockerCompat = true;
            };
            environment.persistence."/persistent" = {
              directories = [
                "/var/lib/containers/storage"
              ];
            };
          };
        };
        homeManager = {
          home.persistence."/persistent".directories = [
            ".local/share/containers/storage"
          ];
        };
      };
    };
}
