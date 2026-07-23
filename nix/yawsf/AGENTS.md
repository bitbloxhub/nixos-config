# YAWSF Development Instructions

- Run `pnpm format` from `nix/yawsf/` after code changes.
- Add HTTP APIs through the Elysia app in `src/lib/server/web-api.ts` and its route modules under `src/lib/server/web-api/routes/`. Do not create standalone SvelteKit API endpoints for web API functionality.
- Keep API response schemas in `src/lib/types.ts` and configure them on Elysia routes.
- Regenerate web API clients after API changes with `pnpm generate:web-api`.
- Regenerate YAWSF host clients with `pnpm generate:yawsf-host-api` when the locked host OpenAPI spec changes.
- Run `pnpm check` after changes.
- Prefer TanStack Query for all API reads; never call generated API functions directly when a generated TanStack Query option exists.
- Use RESTful resource paths and separate endpoints for distinct system actions; do not collapse actions into a generic `/action` endpoint.
