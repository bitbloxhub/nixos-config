import { spawn } from "node:child_process"
import { readdir, readFile } from "node:fs/promises"

import { Elysia } from "elysia"
import { z } from "zod"

import { systemStatusSchema, timezoneSchema } from "$lib/types"
import { services } from "$lib/server/services"
import { eventStream } from "$lib/server/web-api/event-stream"
import { toOpenApiSchema } from "$lib/server/web-api/openapi"
import { readTimezone } from "$lib/server/services/timezone"

const powerSupplyPath = "/sys/class/power_supply"

const systemActionCommands = {
	lock: ["sh", ["-c", "loginctl lock-session; exec hyprlock"]],
	suspend: ["systemctl", ["suspend"]],
	reboot: ["systemctl", ["reboot"]],
	shutdown: ["systemctl", ["poweroff"]],
	logout: ["niri", ["msg", "action", "quit", "--skip-confirmation"]],
} as const

const systemActionResponse = z.object({ ok: z.literal(true) })

function runSystemAction(action: keyof typeof systemActionCommands): { ok: true } {
	const [command, args] = systemActionCommands[action]
	const child = spawn(command, args, { detached: true, stdio: "ignore" })
	child.unref()
	return { ok: true }
}

export const systemRoutes = (app: Elysia) =>
	app
		.post("/system/lock", () => runSystemAction("lock"), {
			detail: { operationId: "lockSystem", tags: ["system"] },
			response: systemActionResponse,
		})
		.post("/system/suspend", () => runSystemAction("suspend"), {
			detail: { operationId: "suspendSystem", tags: ["system"] },
			response: systemActionResponse,
		})
		.post("/system/reboot", () => runSystemAction("reboot"), {
			detail: { operationId: "rebootSystem", tags: ["system"] },
			response: systemActionResponse,
		})
		.post("/system/shutdown", () => runSystemAction("shutdown"), {
			detail: { operationId: "shutdownSystem", tags: ["system"] },
			response: systemActionResponse,
		})
		.post("/system/logout", () => runSystemAction("logout"), {
			detail: { operationId: "logoutSystem", tags: ["system"] },
			response: systemActionResponse,
		})
		.get(
			"/system",
			async ({ set }) => {
				set.headers["cache-control"] = "no-store"
				const battery = await readBattery()
				return { battery }
			},
			{
				detail: { operationId: "getSystemStatus", tags: ["system"] },
				response: systemStatusSchema,
			},
		)
		.get(
			"/timezone",
			async ({ set }) => {
				set.headers["cache-control"] = "no-store"
				return readTimezone()
			},
			{
				detail: { operationId: "getConfiguredTimezone", tags: ["system"] },
				response: timezoneSchema,
			},
		)
		.get(
			"/timezone/events",
			({ request, status }) => {
				const timezone = services()?.timezone
				if (!timezone) return status(503, "Timezone service unavailable")
				return eventStream(request, "timezone", (emit) => timezone.subscribe(emit))
			},
			{
				detail: {
					operationId: "streamTimezone",
					responses: {
						200: {
							content: {
								"text/event-stream": { schema: toOpenApiSchema(timezoneSchema) },
							},
							description: "Timezone updates",
						},
						503: { description: "Timezone service unavailable" },
					},
					tags: ["system"],
				},
			},
		)

interface BatteryStatus {
	capacity: number | null
	charging: boolean
}

async function readBattery(): Promise<BatteryStatus> {
	try {
		const supplies = await readdir(powerSupplyPath)
		const battery = supplies.find((supply) => supply.startsWith("BAT"))
		if (!battery) return { capacity: null, charging: false }

		const [capacity, status, chargerConnected] = await Promise.all([
			readFile(`${powerSupplyPath}/${battery}/capacity`, "utf8"),
			readFile(`${powerSupplyPath}/${battery}/status`, "utf8"),
			readChargerConnected(supplies),
		])
		return {
			capacity: Number.parseInt(capacity, 10),
			charging: status.trim() === "Charging" || chargerConnected,
		}
	} catch {
		return { capacity: null, charging: false }
	}
}

async function readChargerConnected(supplies: string[]): Promise<boolean> {
	const states = await Promise.all(
		supplies
			.filter((supply) => !supply.startsWith("BAT"))
			.map(async (supply) => {
				try {
					const online = await readFile(`${powerSupplyPath}/${supply}/online`, "utf8")
					return online.trim() === "1"
				} catch {
					return false
				}
			}),
	)
	return states.some(Boolean)
}
