# AGENTS.md

## Project Overview

This repository contains multi-host NixOS configurations managed with `flake-parts`, `flake-file`, and `flake-aspects`. It utilizes `import-tree` for modular file management and `treefmt.nix` for code formatting.

## Conventions

- **Module Management**: Use `import-tree` to automatically import modules. Avoid hardcoding paths in `outputs.nix` or `hosts/`.
- **Flake Inputs**: Modularize flake inputs. Define `flake-file.inputs` inside the module or aspect file that utilizes them.
- **Flake Generation**: Do NOT edit `flake.nix` manually. Make changes to inputs or modules, then run `nix run .#write-flake` to regenerate.
- **Commit Style**: Use conventional commits (e.g., `feat:`, `fix:`, `chore:`, `docs:`).

## Available Skills

Use the following skills available in `.agent/skills/`:

- **`/skill:flake-aspects`**: Use for defining and modifying flake aspects and transposition (`<aspect>.<class>` -> `flake.modules.<class>.<aspect>`).
- **`/skill:flake-file`**: Use for managing flake inputs and generating `flake.nix` via `nix run .#write-flake`.
- **`/skill:import-tree`**: Use for managing directory imports in `outputs.nix` and `hosts/`.

## Structure

- **`flake-file.nix`**: Flake definition based on module setup. Use this to add/remove inputs.
- **`ci.nix`**: GitHub Actions workflows configuration via `actions-nix` and `nix-auto-ci`.
- **`outputs.nix`**: Defines the flake's output schemas and structural outputs.
- **`modules/`**: Nix module declarations auto-imported for flake outputs and configurations (using `import-tree`).
- **`hosts/`**: System configurations organized per host.
- **`.agent/skills/`**: Custom agent-browser/capability skills for project-specific automation.

## Development Workflow

### Modifying Modules

1.  Identify the aspect in `modules/` or create a new one.
2.  Add flake inputs to the module if necessary (following input localization convention).
3.  Add/modify the logic within the aspect.
4.  Run `nix run .#write-flake` to update `flake.nix`.

### Adding Hosts

1.  Create a host directory in `hosts/`.
2.  Ensure `hosts/default.nix` (or `import-tree` equivalent) picks up new hosts correctly.

### Formatting

- The project is configured with `treefmt-nix`. Run `nix fmt` before committing to ensure formatting compliance.

## Testing and CI

- **Build Check**: Run `nix flake check` to verify closure validity and formatting.
- **CI**: GitHub actions are managed via `actions-nix` in `ci.nix`. Changes here are automatically picked up.
