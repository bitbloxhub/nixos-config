{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      treefmt = {
        programs.xmllint.enable = true;
        programs.xmllint.package = pkgs.symlinkJoin {
          name = "libxml2-wrapped";
          paths = [ pkgs.libxml2 ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/xmllint \
              --set XMLLINT_INDENT "${"\t"}"
          '';
        };
      };
    };
}
