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
          pkgs.lua-language-server
        ];
      };
    };
}
