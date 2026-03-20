---
name: flake-file
description: Use this skill for generating `flake.nix` from modular Nix options, managing flake inputs, and defining custom output schemas. Essential for maintainable, type-safe, and aggregateable Nix flakes. Trigger this skill whenever you need to regenerate `flake.nix`, define complex input/output schemas with Nix types, or bridge non-flake/stable-nix environments (npins, unflake, nixlock) with flake-based setups.
---

# flake-file

`flake-file` treats `flake.nix` definitions as functional, aggregateable Nix modules, allowing you to use the full power of the Nix language (including `lib.mkDefault`) to manage your flake configuration.

## When to use (Trigger me!)

- **Regenerating Flakes**: When you need to update `flake.nix` via `nix run .#write-flake`.
- **Modular Input Management**: When flake inputs need to be broken down into smaller, aggregateable modules rather than defined in one monolithic file.
- **Typed Schemas**: When you want type-safe input and output schemas for your flake.
- **Environment Bridging**: When you need to use `flake-file` functionality within stable Nix, non-flake, or alternative lockfile environments (npins, unflake, nixlock).

## Core Concepts

- **Nix-Module-Powered Definitions**: Your `flake.nix` is built from aggregation of modules.
- **Type-Safe Schemas**: Define inputs and outputs using formal Nix types.
- **Native Support**: Uses `nixConfig` and `follows` syntax identical to native flakes.
- **Ensured Consistency**: `flake check` automatically verifies `flake.nix` is up-to-date with your definitions.

## Examples & Patterns

### Modularizing Flake Inputs

Define flake inputs right next to the module/aspect that requires them:

```nix
# In your aspect/module definition
{ inputs, ... }: {
  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
```

## Workflow Pattern

1. **Define**: Add `flake-file` module options in your relevant aspect definition files (keep it close to the code that uses the inputs).
2. **Setup**: If bootstrapping, rename existing `flake.nix` to `flake-file.nix` and run the bootstrap script.
3. **Generate**: After changes, run `nix run .#write-flake` to regenerate.
4. **Verify**: Always run `flake check` to ensure your generated `flake.nix` hasn't drifted from your module definitions.
