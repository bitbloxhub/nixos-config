import { openapi } from "@elysia/openapi"
import { Elysia } from "elysia"
import { z } from "zod"

import { mediaRoutes } from "./web-api/routes/media"
import { notificationRoutes } from "./web-api/routes/notifications"
import { mprisRoutes } from "./web-api/routes/mpris"
import { niriRoutes } from "./web-api/routes/niri"

import { bentoRoutes } from "./web-api/routes/bento"
import { cavaRoutes } from "./web-api/routes/cava"
import { systemRoutes } from "./web-api/routes/system"

export const webApi = new Elysia({ prefix: "/api" })
	.use(
		openapi({
			documentation: {
				info: {
					title: "Bitbloxhub Shell Web API",
					version: "0.0.1",
				},
			},
			mapJsonSchema: {
				zod: (schema: z.ZodType) => z.toJSONSchema(schema, { target: "openapi-3.0" }),
			},
			path: "/openapi",
			provider: null,
			specPath: "/openapi.json",
		}),
	)
	.use(mediaRoutes)
	.use(mprisRoutes)
	.use(notificationRoutes)
	.use(bentoRoutes)
	.use(cavaRoutes)
	.use(niriRoutes)
	.use(systemRoutes)
