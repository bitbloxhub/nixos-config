import { z } from "zod"

export const mprisPlayerSchema = z.object({
	serviceName: z.string(),
	identity: z.string(),
	playbackStatus: z.string(),
	title: z.string(),
	artist: z.string(),
	album: z.string(),
	artUrl: z.string(),
	position: z.number(),
	length: z.number(),
	canPlay: z.boolean(),
	canPause: z.boolean(),
	canGoNext: z.boolean(),
	canGoPrevious: z.boolean(),
})
export const mprisPlayersSchema = z.array(mprisPlayerSchema)
export type MprisPlayer = z.infer<typeof mprisPlayerSchema>

export const notificationActionSchema = z.object({
	id: z.string(),
	label: z.string(),
})
export const notificationSchema = z.object({
	id: z.number().int().positive(),
	appName: z.string(),
	appIcon: z.string(),
	summary: z.string(),
	body: z.string(),
	actions: z.array(notificationActionSchema),
	urgency: z.number().int().min(0).max(2),
	category: z.string(),
	resident: z.boolean(),
	transient: z.boolean(),
	receivedAt: z.number().int().nonnegative(),
	expiresAt: z.number().int().positive().nullable(),
	visualExpiresAt: z.number().int().positive().nullable(),
})
export const notificationsSchema = z.array(notificationSchema)
export type NotificationAction = z.infer<typeof notificationActionSchema>
export type Notification = z.infer<typeof notificationSchema>

export const niriWorkspaceSchema = z.object({
	id: z.number(),
	idx: z.number(),
	name: z.string().nullable(),
	output: z.string().nullable(),
	is_urgent: z.boolean(),
	is_active: z.boolean(),
	is_focused: z.boolean(),
	active_window_id: z.number().nullable(),
})
export const niriWorkspacesSchema = z.array(niriWorkspaceSchema)
export const niriEventSchema = z.object({}).catchall(z.unknown())
export type NiriWorkspace = z.infer<typeof niriWorkspaceSchema>
export type NiriEvent = z.infer<typeof niriEventSchema>

export const batteryStatusSchema = z.object({
	capacity: z.number().nullable(),
	charging: z.boolean(),
})
export const systemStatusSchema = z.object({
	battery: batteryStatusSchema,
})
export type SystemStatus = z.infer<typeof systemStatusSchema>

export const timezoneSchema = z.object({
	timezone: z.string(),
})
export type Timezone = z.infer<typeof timezoneSchema>
