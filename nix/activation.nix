{
  flake.grove.projectors.user.homeManager =
    _user:
    {
      lib,
      config,
      ...
    }:
    {
      # FIX: For lix activation, see https://github.com/nix-community/home-manager/issues/8786#issuecomment-3964961582
      home.activation.installPackages = lib.mkForce (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          nixProfileRemove home-manager-path
          if [[ -e ${config.home.profileDirectory}/manifest.json ]]; then
            run nix profile install ${config.home.path}
          else
            run nix-env -i ${config.home.path}
          fi
        ''
      );
    };
}
