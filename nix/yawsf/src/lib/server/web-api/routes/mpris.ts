import { Elysia } from "elysia"
import { z } from "zod"

import { mprisPlayersSchema } from "$lib/types"
import { services } from "$lib/server/services"
import { eventStream } from "$lib/server/web-api/event-stream"
import { toOpenApiSchema } from "$lib/server/web-api/openapi"

const mprisActionParamsSchema = z.object({
	serviceName: z.string().min(1),
	action: z.enum(["playPause", "next", "previous", "seek"]),
})
const mprisSeekSchema = z.object({ offset: z.number().finite().optional() })
const commandResultSchema = z.object({ ok: z.literal(true) })

export const mprisRoutes = (app: Elysia) =>
	app
		.get("/mpris", () => services()?.mpris.players() ?? [], {
			detail: { operationId: "listMprisPlayers", tags: ["mpris"] },
			response: mprisPlayersSchema,
		})
		.post(
			"/mpris/:serviceName/actions/:action",
			async ({ params, body, status }) => {
				const mpris = services()?.mpris
				if (!mpris) return status(503, "MPRIS unavailable")

				if (params.action === "playPause") await mpris.playPause(params.serviceName)
				else if (params.action === "next") await mpris.next(params.serviceName)
				else if (params.action === "previous") await mpris.previous(params.serviceName)
				else if (body.offset !== undefined)
					await mpris.seek(params.serviceName, body.offset)

				return { ok: true as const }
			},
			{
				params: mprisActionParamsSchema,
				body: mprisSeekSchema,
				detail: { operationId: "actOnMprisPlayer", tags: ["mpris"] },
				response: { 200: commandResultSchema, 503: z.string() },
			},
		)
		.get(
			"/mpris/events",
			({ request, status }) => {
				const mpris = services()?.mpris
				if (!mpris) return status(503, "MPRIS unavailable")
				return eventStream(request, "players", (emit) => mpris.subscribe(emit))
			},
			{
				detail: {
					operationId: "streamMprisPlayers",
					responses: {
						200: {
							content: {
								"text/event-stream": {
									schema: toOpenApiSchema(mprisPlayersSchema),
								},
							},
							description: "MPRIS player updates",
						},
						503: { description: "MPRIS unavailable" },
					},
					tags: ["mpris"],
				},
			},
		)
