{
  inputs,
  lib,
}:
(lib.evalModules {
  modules =
    [
      {
        options.lib = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
        };
      }
    ]
    ++ (builtins.map (x: import x { inherit lib inputs; }) (
      ((inputs.import-tree.withLib lib).filterNot (lib.hasSuffix "default.nix")).leafs ./.
    ));
}).config.lib
