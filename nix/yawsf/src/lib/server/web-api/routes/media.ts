import { Elysia } from "elysia"

import { mediaAsset } from "$lib/server/media-assets"

export const mediaRoutes = (app: Elysia) =>
	app.get("/media/:id", ({ params }) => mediaAsset(params.id))
