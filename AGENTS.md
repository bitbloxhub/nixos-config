# AGENTS.md

## Project Overview

This repository contains multi-host NixOS configurations managed with `flake-parts`, `flake-file`, and `nix-grove`. The flake is generated from `nix/flake-file.nix`, and modules are auto-imported from `./nix` using `import-tree`. Formatting is handled with `treefmt-nix`.

## Conventions

- **Module Management**: Use `import-tree` and keep modules inside `nix/`. Define typed Grove instances and projectors instead of hardcoding module paths.
- **Grove Architecture**: Host instances own host-wide settings, hostnames, and attached user IDs. User instances own usernames, home settings, and user features. User projectors may target Home Manager and NixOS; host projectors may target NixOS and system-manager.
- **Host/User Attachment**: User IDs always use `username@host` format. Configure attachments with `host.<name>.users = [ "username@host" ];`. Do not add `hostname` to user instances.
- **Flake Inputs**: Modularize flake inputs. Define `flake-file.inputs` in the module that needs them.
- **Flake Generation**: Do NOT edit `flake.nix` manually. Update source modules, then run `nix run .#write-flake`.
- **Commit Style**: Use conventional commits (e.g., `feat:`, `fix:`, `chore:`, `docs:`).
- **Nix Formatting Style**: For NixOS, system-manager, and Home Manager module functions, keep arguments split across multiple lines.
- **Nix Spacing Style**: Preserve intentional blank lines between logical sections.

## Project Skills

No project-specific skills are currently installed.

## Structure

- **`flake.nix`**: Generated file. Do not edit directly.
- **`nix/flake-file.nix`**: Source flake definition and input declarations.
- **`nix/ci.nix`**: GitHub Actions/CI configuration via `actions-nix` and `nix-auto-ci`.
- **`nix/hosts.nix`**: Grove host types, host/user attachment, and shared configuration builders (`self.lib.configs.*`).
- **`nix/hosts/`**: Per-host Grove instances, host projectors, deployment outputs, and host-specific configuration.
- **`nix/`**: Main module tree auto-imported by `import-tree`; feature modules expose Grove types and projectors.

## Development Workflow

### Modifying Modules

1. Identify the target module in `nix/` or create one.
2. Add required `flake-file.inputs` in the module that uses them.
3. Define or update Grove types, instances, and projectors.
4. Run `nix fmt`, `nix run .#write-flake`.
5. Validate with `nix flake check`.

### Adding Hosts

1. Create a host directory under `nix/hosts/<host>/` with `default.nix`.
2. Define `grove.host.<host>` with `hostname` and attached user IDs in `username@host` format.
3. Define matching `grove.user."username@host"` instances with no hostname.
4. Add relevant outputs: `nixosConfigurations`, `homeConfigurations`, `systemConfigs`, and/or deployment outputs.
5. Ensure the module is picked up by `import-tree`.

### Formatting

- Run `nix fmt` before committing (configured via `treefmt-nix`).

## Testing and CI

- **Build Check**: Run `nix flake check` to verify evaluation and formatting.
- **Generated Files**: Run `nix run .#write-flake` and `nix run .#write-lock` after source changes.
- **Migration Check**: Confirm `rg 'flake\.aspects|self\.modules|aspects\.' nix` returns no matches.
- **CI**: GitHub Actions are defined in `nix/ci.nix` and generated from flake outputs.
