import { Elysia } from "elysia"
import { z } from "zod"

import { niriEventSchema, niriWorkspacesSchema } from "$lib/types"
import { services } from "$lib/server/services"
import { eventStream } from "$lib/server/web-api/event-stream"
import { toOpenApiSchema } from "$lib/server/web-api/openapi"

const focusWorkspaceSchema = z.object({
	index: z.number().int().positive(),
})
const commandResultSchema = z.object({ ok: z.literal(true) })

export const niriRoutes = (app: Elysia) =>
	app
		.get("/niri", () => services()?.niri.workspaces() ?? [], {
			detail: { operationId: "listNiriWorkspaces", tags: ["niri"] },
			response: niriWorkspacesSchema,
		})
		.post(
			"/niri/focus-workspace",
			async ({ body, status }) => {
				const niri = services()?.niri
				if (!niri) return status(503, "Niri unavailable")
				await niri.focusWorkspace(body.index)
				return { ok: true as const }
			},
			{
				body: focusWorkspaceSchema,
				detail: { operationId: "focusNiriWorkspace", tags: ["niri"] },
				response: { 200: commandResultSchema, 503: z.string() },
			},
		)
		.get(
			"/niri/events",
			({ request, status }) => {
				const niri = services()?.niri
				if (!niri) return status(503, "Niri unavailable")
				return eventStream(request, "niri", (emit) => niri.subscribe(emit))
			},
			{
				detail: {
					operationId: "streamNiriEvents",
					responses: {
						200: {
							content: {
								"text/event-stream": {
									schema: toOpenApiSchema(niriEventSchema),
								},
							},
							description: "Raw Niri event updates",
						},
						503: { description: "Niri unavailable" },
					},
					tags: ["niri"],
				},
			},
		)
