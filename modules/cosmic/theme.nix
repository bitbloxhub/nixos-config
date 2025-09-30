{
  inputs,
  ...
}:
{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      ...
    }:
    let
      # TODO: get rid of this hack when https://github.com/NixOS/nixpkgs/pull/440544 is merged
      inherit
        (
          ((import "${inputs.cosmic-manager}/lib/ron.nix") {
            lib = lib // {
              cosmic = (import "${inputs.cosmic-manager}/lib/modules.nix") { inherit lib; };
            };
          })
        )
        importRON
        ;
    in
    {
      wayland.desktopManager.cosmic.appearance.theme.dark =
        importRON "${inputs.catppuccin-cosmic}/themes/cosmic-settings/catppuccin-${config.my.themes.catppuccin.flavor}-${config.my.themes.catppuccin.accent}+round.ron";

      wayland.desktopManager.cosmic.configFile = {
        "com.system76.CosmicTheme.Mode" = {
          version = 1;
          entries.is_dark = true;
        };
      };
    };
}
