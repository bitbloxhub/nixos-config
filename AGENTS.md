# AGENTS.md

## Project Overview

This repository contains multi-host NixOS configurations managed with `flake-parts`, `flake-file`, and `flake-aspects`. The flake is generated from `nix/flake-file.nix`, and modules are auto-imported from `./nix` using `import-tree`. Formatting is handled with `treefmt-nix`.

## Conventions

- **Module Management**: Use `import-tree` and keep modules inside `nix/`. Avoid hardcoding module paths in generated files.
- **Flake Inputs**: Modularize flake inputs. Define `flake-file.inputs` in the module/aspect that needs them.
- **Flake Generation**: Do NOT edit `flake.nix` manually. Update source modules, then run `nix run .#write-flake`.
- **Commit Style**: Use conventional commits (e.g., `feat:`, `fix:`, `chore:`, `docs:`).
- **Nix Formatting Style**: In `flake.aspects` declarations, keep flake-aspect function arguments on one line (for example, `{ aspect, ... }:`). For NixOS, system-manager, and home-manager module functions, keep arguments split across multiple lines.
- **Nix Spacing Style**: Preserve intentional blank lines between logical sections, but do not insert an extra blank line after `includes = ...;` before the next attribute in an aspect attrset.

## Available Skills

Use the following skills available in `.pi/skills/`:

- **`/skill:flake-aspects`**: Use for defining/modifying flake aspects and transposition (`<aspect>.<class>` -> `flake.modules.<class>.<aspect>`).
- **`/skill:flake-file`**: Use for managing flake inputs and regenerating `flake.nix` via `nix run .#write-flake`.
- **`/skill:import-tree`**: Use for directory-tree imports in the `nix/` module tree.

## Structure

- **`flake.nix`**: Generated file. Do not edit directly.
- **`nix/flake-file.nix`**: Source flake definition and input declarations.
- **`nix/ci.nix`**: GitHub Actions/CI configuration via `actions-nix` and `nix-auto-ci`.
- **`nix/hosts.nix`**: Shared host config builders (`self.lib.configs.*`).
- **`nix/hosts/`**: Per-host definitions (for example `nixos-bill`, `extreme-creeper`).
- **`nix/`**: Main module/aspect tree auto-imported by `import-tree`.
- **`.pi/skills/`**: Project-specific agent skills.

## Development Workflow

### Modifying Modules

1.  Identify target module/aspect in `nix/` (or create one).
2.  Add flake inputs in `nix/flake-file.nix` context if required.
3.  Add/modify module logic.
4.  Run `nix run .#write-flake` to regenerate `flake.nix`.

### Adding Hosts

1.  Create a host directory under `nix/hosts/<host>/` with `default.nix`.
2.  Define host outputs/aspects in that host module (for example `flake.nixosConfigurations`, `flake.systemConfigs`, `flake.homeConfigurations`, `flake.deploy.nodes`).
3.  Ensure host module is picked up by `import-tree` under `./nix`.

### Formatting

- Run `nix fmt` before committing (configured via `treefmt-nix`).

## Testing and CI

- **Build Check**: Run `nix flake check` to verify evaluations and formatting.
- **CI**: GitHub Actions are defined in `nix/ci.nix` and generated from flake outputs.
