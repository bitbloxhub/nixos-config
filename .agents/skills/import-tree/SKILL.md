---
name: import-tree
description: Use this skill for managing, traversing, and importing entire directory trees of Nix modules (e.g., across `outputs.nix`, `hosts/`, or `modules/`) with powerful attribute-based filtering. Trigger this skill whenever you need to import multiple Nix files from a directory, filter out specific subdirectories/files (like `npins`, `flake.nix`, or `README.md`), or structure your imports to naturally map to the file hierarchy.
---

# import-tree

`import-tree` enables automatic, tree-based importing of Nix modules, mapping directory structures directly into your Nix configuration attributes.

## When to use (Trigger me!)

- **Recursive Imports**: When you need to import all modules in a directory or submodule recursively instead of manually listing them.
- **Dynamic Filtering**: When you need to exclude specific files or directories from an import path.
- **Structural Mapping**: When your Nix attribute set structure exactly mirrors your filesystem structure.

## Core Concepts

- **Automatic Traversal**: Recursively scans directories to collect Nix files.
- **Composable Filtering**: Use `filter`, `filterNot`, `hasSuffix`, `hasPrefix` to whitelist/blacklist files.
- **Hierarchy Mapping**: Filesystem paths naturally become part of the resulting Nix attribute set.

## Common Patterns

### Importing All Modules (excluding specific files)

Use `import-tree` to import all modules in a directory while filtering out non-module files:

```nix
# In outputs.nix
{ lib, ... }: {
  my-modules =
    (import-tree.filterNot (lib.hasSuffix "default.nix")) ./modules;
}
```

### Filtering Nested Packages

When importing a whole directory but needing to ignore specific tools or generated files:

```nix
# In hosts/configuration.nix
{ lib, ... }: {
  imports = [
    (import-tree.filter (path: !lib.hasInfix "experimental") ./services)
  ];
}
```

### Mapping Directory Structure to Attributes

Useful when the directory layout _is_ your configuration layout:

```nix
# Naturally maps /hosts/laptop/default.nix to { laptop = ...; }
hosts = import-tree ./hosts;
```
