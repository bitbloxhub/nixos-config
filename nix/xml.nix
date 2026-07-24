{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      treefmt.programs.xmllint = {
        enable = true;
        package = pkgs.symlinkJoin {
          buildInputs = [ pkgs.makeWrapper ];
          name = "libxml2-wrapped";
          paths = [ pkgs.libxml2 ];
          postBuild = ''
            wrapProgram $out/bin/xmllint \
              --set XMLLINT_INDENT "${"\t"}"
          '';
        };
      };
    };
}
