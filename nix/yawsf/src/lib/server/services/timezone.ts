import { unwatchFile, watchFile } from "node:fs"
import { readFile } from "node:fs/promises"
import { env } from "node:process"

import type { Timezone } from "$lib/types"

export type TimezoneListener = (timezone: Timezone) => void

export interface TimezoneService {
	current(): Timezone
	subscribe(listener: TimezoneListener): () => void
	stop(): Promise<void>
}

const timezonePath = () => {
	const configHome = env.XDG_CONFIG_HOME ?? `${env.HOME}/.config`
	return `${configHome}/localtimezone`
}

export async function readTimezone(): Promise<Timezone> {
	const timezone = await readFile(timezonePath(), "utf8").catch(() => "UTC")
	return {
		timezone: timezone.trim() || "UTC",
		systemTimezone: new Intl.DateTimeFormat().resolvedOptions().timeZone ?? "UTC",
	}
}

export async function startTimezone(): Promise<TimezoneService> {
	const path = timezonePath()
	const listeners = new Set<TimezoneListener>()
	let current = await readTimezone()
	let stopped = false
	let updateTimer: ReturnType<typeof setTimeout> | null = null

	const notify = async () => {
		if (stopped) return
		current = await readTimezone()
		for (const listener of listeners) listener(current)
	}
	const scheduleUpdate = () => {
		if (updateTimer) clearTimeout(updateTimer)
		updateTimer = setTimeout(() => {
			updateTimer = null
			void notify()
		}, 50)
		updateTimer.unref()
	}

	watchFile(path, { interval: 250, persistent: false }, (previous, next) => {
		if (previous.mtimeMs !== next.mtimeMs || previous.size !== next.size) scheduleUpdate()
	})

	return {
		current: () => current,
		subscribe(listener) {
			listeners.add(listener)
			listener(current)
			return () => listeners.delete(listener)
		},
		async stop() {
			stopped = true
			if (updateTimer) clearTimeout(updateTimer)
			unwatchFile(path)
			listeners.clear()
		},
	}
}
