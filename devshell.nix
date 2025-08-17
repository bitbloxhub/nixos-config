{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos-config";
        packages = [
          pkgs.nixfmt-rfc-style
          pkgs.deadnix
          pkgs.statix
          pkgs.stylua
          pkgs.ast-grep
          pkgs.lua-language-server
          pkgs.typescript-language-server
          pkgs.nodejs_24
          pkgs.prettier
          (inputs.ags.packages.${pkgs.system}.ags.override {
            extraPackages = lib.my.agsExtraPackagesForPkgs pkgs;
          })
        ];
      };
    };
}
