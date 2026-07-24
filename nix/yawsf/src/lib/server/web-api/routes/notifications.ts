import { Elysia } from "elysia"
import { z } from "zod"

import { notificationsSchema } from "$lib/types"
import { services } from "$lib/server/services"
import { eventStream } from "$lib/server/web-api/event-stream"
import { toOpenApiSchema } from "$lib/server/web-api/openapi"

const notificationIdParamsSchema = z.object({ id: z.coerce.number().int().positive() })
const notificationActionParamsSchema = z.object({
	id: z.coerce.number().int().positive(),
	actionId: z.string().min(1),
})
const commandResultSchema = z.object({ ok: z.literal(true) })
const notificationResizeSchema = z.object({ height: z.number().finite().min(0).max(10000) })
const notificationEventsQuerySchema = z.object({
	surface: z.enum(["visual", "all"]).default("visual"),
})

export const notificationRoutes = (app: Elysia) =>
	app
		.get(
			"/notifications",
			({ status }) => {
				const notifications = services()?.notifications
				if (!notifications?.available()) return status(503, "Notifications unavailable")
				return notifications.notifications()
			},
			{
				detail: { operationId: "listNotifications", tags: ["notifications"] },
				response: { 200: notificationsSchema, 503: z.string() },
			},
		)
		.post(
			"/notifications/resize",
			async ({ body, status }) => {
				const notificationWindows = services()?.notificationWindows
				if (!notificationWindows) return status(503, "Notifications unavailable")

				await notificationWindows.resize(body.height)
				return { ok: true as const }
			},
			{
				body: notificationResizeSchema,
				detail: { operationId: "resizeNotifications", tags: ["notifications"] },
				response: { 200: commandResultSchema, 503: z.string() },
			},
		)
		.delete(
			"/notifications/:id",
			({ params, status }) => {
				const notifications = services()?.notifications
				if (!notifications?.available()) return status(503, "Notifications unavailable")
				if (notifications.dismiss(params.id)) return { ok: true as const }
				return status(404, "Notification not found")
			},
			{
				params: notificationIdParamsSchema,
				detail: { operationId: "dismissNotification", tags: ["notifications"] },
				response: { 200: commandResultSchema, 404: z.string(), 503: z.string() },
			},
		)
		.post(
			"/notifications/:id/actions/:actionId",
			({ params, status }) => {
				const notifications = services()?.notifications
				if (!notifications?.available()) return status(503, "Notifications unavailable")
				if (notifications.invokeAction(params.id, params.actionId))
					return { ok: true as const }
				return status(404, "Notification or action not found")
			},
			{
				params: notificationActionParamsSchema,
				detail: { operationId: "invokeNotificationAction", tags: ["notifications"] },
				response: { 200: commandResultSchema, 404: z.string(), 503: z.string() },
			},
		)
		.get(
			"/notifications/events",
			({ request, query, status }) => {
				const notifications = services()?.notifications
				if (!notifications?.available()) return status(503, "Notifications unavailable")
				return eventStream(request, "notifications", (emit) =>
					query.surface === "visual"
						? notifications.subscribeVisual(emit)
						: notifications.subscribe(emit),
				)
			},
			{
				query: notificationEventsQuerySchema,
				detail: {
					operationId: "streamNotifications",
					responses: {
						200: {
							content: {
								"text/event-stream": {
									schema: toOpenApiSchema(notificationsSchema),
								},
							},
							description: "Notification updates",
						},
						503: { description: "Notifications unavailable" },
					},
					tags: ["notifications"],
				},
			},
		)
