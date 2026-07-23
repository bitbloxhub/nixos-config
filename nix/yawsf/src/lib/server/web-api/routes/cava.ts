import { Elysia } from "elysia"
import { z } from "zod"

import { services } from "$lib/server/services"
import { eventStream } from "$lib/server/web-api/event-stream"
import { toOpenApiSchema } from "$lib/server/web-api/openapi"

const cavaFrameSchema = z.array(z.number())

export const cavaRoutes = (app: Elysia) =>
	app.get(
		"/cava/events",
		({ request, status }) => {
			const cava = services()?.cava
			if (!cava) return status(503, "Cava unavailable")
			return eventStream(request, "cava", (emit) => cava.subscribe(emit))
		},
		{
			detail: {
				operationId: "streamCava",
				responses: {
					200: {
						content: {
							"text/event-stream": { schema: toOpenApiSchema(cavaFrameSchema) },
						},
						description: "Cava audio frames",
					},
					503: { description: "Cava unavailable" },
				},
				tags: ["cava"],
			},
		},
	)
