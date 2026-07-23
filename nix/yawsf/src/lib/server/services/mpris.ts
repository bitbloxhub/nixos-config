import { mediaAssetUrl } from "$lib/server/media-assets"

import * as dbus from "@jellybrick/dbus-next"
import type { MessageBus, ProxyInterface, Variant } from "@jellybrick/dbus-next"
import type { MprisPlayer } from "$lib/types"

const playerInterfaceName = "org.mpris.MediaPlayer2.Player"
const propertiesInterfaceName = "org.freedesktop.DBus.Properties"
const dbusInterfaceName = "org.freedesktop.DBus"
const dbusName = "org.freedesktop.DBus"
const dbusPath = "/org/freedesktop/DBus"
const rootPath = "/org/mpris/MediaPlayer2"
const playerPrefix = "org.mpris.MediaPlayer2."

type PlayerProxy = ProxyInterface & {
	PlayPause: () => Promise<void>
	Next: () => Promise<void>
	Previous: () => Promise<void>
	Stop: () => Promise<void>
	Seek: (offset: number) => Promise<void>
}

type PropertiesProxy = ProxyInterface & {
	GetAll: (interfaceName: string) => Promise<Record<string, Variant>>
}

type MprisListener = (players: MprisPlayer[]) => void

export interface MprisService {
	players(): MprisPlayer[]
	subscribe(listener: MprisListener): () => void
	playPause(serviceName: string): Promise<void>
	next(serviceName: string): Promise<void>
	previous(serviceName: string): Promise<void>
	seek(serviceName: string, offsetSeconds: number): Promise<void>
	stop(): Promise<void>
}

interface PlayerEntry {
	data: MprisPlayer
	player: PlayerProxy
	properties: PropertiesProxy
	propertiesChanged: (...args: unknown[]) => void
}

export async function startMpris(): Promise<MprisService> {
	const listeners = new Set<MprisListener>()
	const entries = new Map<string, PlayerEntry>()
	let bus: MessageBus | null = null
	let stopped = false
	let refreshing = false
	let positionTimer: ReturnType<typeof setInterval> | null = null

	const notify = () => {
		const current = [...entries.values()].map((entry) => entry.data)
		for (const listener of listeners) {
			listener(current)
		}
	}

	const refreshPlayer = async (entry: PlayerEntry) => {
		const values = await entry.properties.GetAll(playerInterfaceName)
		const metadata = unwrap(values.Metadata) as Record<string, unknown> | undefined
		const artists = metadata?.["xesam:artist"]
		const title = metadata?.["xesam:title"]
		const album = metadata?.["xesam:album"]

		entry.data = {
			...entry.data,
			identity: stringValue(values.Identity, entry.data.identity),
			playbackStatus: stringValue(values.PlaybackStatus, entry.data.playbackStatus),
			title: stringValue(title, ""),
			artist: stringArrayValue(artists),
			album: stringValue(album, ""),
			artUrl: mediaAssetUrl(stringValue(metadata?.["mpris:artUrl"], "")),
			position: numberValue(values.Position, 0),
			length: numberValue(metadata?.["mpris:length"], 0),
			canPlay: booleanValue(values.CanPlay),
			canPause: booleanValue(values.CanPause),
			canGoNext: booleanValue(values.CanGoNext),
			canGoPrevious: booleanValue(values.CanGoPrevious),
		}
	}

	const addPlayer = async (serviceName: string) => {
		if (!bus || entries.has(serviceName)) {
			return
		}

		try {
			const object = await bus.getProxyObject(serviceName, rootPath)
			const player = object.getInterface(playerInterfaceName) as PlayerProxy
			const properties = object.getInterface(propertiesInterfaceName) as PropertiesProxy
			const entry: PlayerEntry = {
				data: emptyPlayer(serviceName),
				player,
				properties,
				propertiesChanged: () => undefined,
			}

			entry.propertiesChanged = (interfaceName: unknown) => {
				if (interfaceName !== playerInterfaceName) return
				void refreshPlayer(entry).then(notify).catch(ignoreError)
			}

			properties.on("PropertiesChanged", entry.propertiesChanged)
			entries.set(serviceName, entry)
			await refreshPlayer(entry)
		} catch {
			// A player can disappear between ListNames and introspection.
		}
	}

	const refresh = async () => {
		if (!bus || stopped || refreshing) {
			return
		}

		refreshing = true
		try {
			const object = await bus.getProxyObject(dbusName, dbusPath)
			const dbusInterface = object.getInterface(dbusInterfaceName) as ProxyInterface & {
				ListNames: () => Promise<string[]>
			}
			const names = await dbusInterface.ListNames()
			const playerNames = names.filter((name) => name.startsWith(playerPrefix))

			for (const serviceName of playerNames) {
				await addPlayer(serviceName)
			}
			for (const [serviceName, entry] of entries) {
				if (!playerNames.includes(serviceName)) {
					entry.properties.off("PropertiesChanged", entry.propertiesChanged)
					entries.delete(serviceName)
				}
			}
			notify()
		} finally {
			refreshing = false
		}
	}

	const refreshPositions = () => {
		if (stopped) return
		void Promise.all([...entries.values()].map(refreshPlayer))
			.then(notify)
			.catch(ignoreError)
	}

	try {
		const sessionBus = dbus.sessionBus()
		bus = sessionBus
		const object = await sessionBus.getProxyObject(dbusName, dbusPath)
		const dbusInterface = object.getInterface(dbusInterfaceName) as ProxyInterface
		dbusInterface.on("NameOwnerChanged", () => void refresh())
		await refresh()
		positionTimer = setInterval(refreshPositions, 1000)
	} catch (error) {
		console.warn("MPRIS unavailable", error)
	}

	return {
		players: () => [...entries.values()].map((entry) => entry.data),
		subscribe(listener) {
			listeners.add(listener)
			listener([...entries.values()].map((entry) => entry.data))
			return () => listeners.delete(listener)
		},
		async playPause(serviceName) {
			await entries.get(serviceName)?.player.PlayPause()
		},
		async next(serviceName) {
			await entries.get(serviceName)?.player.Next()
		},
		async previous(serviceName) {
			await entries.get(serviceName)?.player.Previous()
		},
		async seek(serviceName, offsetSeconds) {
			await entries.get(serviceName)?.player.Seek(offsetSeconds * 1_000_000)
		},
		async stop() {
			stopped = true
			if (positionTimer) clearInterval(positionTimer)
			for (const entry of entries.values()) {
				entry.properties.off("PropertiesChanged", entry.propertiesChanged)
			}
			entries.clear()
			listeners.clear()
			bus?.disconnect()
		},
	}
}

function emptyPlayer(serviceName: string): MprisPlayer {
	return {
		serviceName,
		identity: serviceName.slice(playerPrefix.length),
		playbackStatus: "Stopped",
		title: "",
		artist: "",
		album: "",
		artUrl: "",
		position: 0,
		length: 0,
		canPlay: false,
		canPause: false,
		canGoNext: false,
		canGoPrevious: false,
	}
}

function unwrap(value: unknown): unknown {
	if (value && typeof value === "object" && "value" in value) {
		return unwrap((value as Variant).value)
	}
	return value
}

function stringValue(value: unknown, fallback: string): string {
	const unwrapped = unwrap(value)
	return typeof unwrapped === "string" ? unwrapped : fallback
}

function stringArrayValue(value: unknown): string {
	const unwrapped = unwrap(value)
	return Array.isArray(unwrapped)
		? unwrapped
				.map((item) => stringValue(item, ""))
				.filter(Boolean)
				.join(", ")
		: stringValue(value, "")
}

function booleanValue(value: unknown): boolean {
	return unwrap(value) === true
}

function numberValue(value: unknown, fallback: number): number {
	const unwrapped = unwrap(value)
	return typeof unwrapped === "number"
		? unwrapped
		: typeof unwrapped === "bigint"
			? Number(unwrapped)
			: fallback
}

function ignoreError(): void {}
