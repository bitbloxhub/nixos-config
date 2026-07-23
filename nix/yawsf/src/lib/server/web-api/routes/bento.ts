import { Elysia } from "elysia"
import { z } from "zod"

import { services } from "$lib/server/services"

const bentoActionSchema = z.object({ action: z.enum(["open", "close", "toggle"]) })
const commandResultSchema = z.object({ ok: z.literal(true) })

export const bentoRoutes = (app: Elysia) =>
	app.post(
		"/bento",
		async ({ body, status }) => {
			const bento = services()?.bentoWindows
			if (!bento) return status(503, "Bento unavailable")
			await bento[body.action]()
			return { ok: true as const }
		},
		{
			body: bentoActionSchema,
			detail: { operationId: "controlBento", tags: ["bento"] },
			response: { 200: commandResultSchema, 503: z.string() },
		},
	)
