import { mediaAssetUrl } from "$lib/server/media-assets"

import * as dbus from "@jellybrick/dbus-next"
import type { MessageBus, Variant } from "@jellybrick/dbus-next"

import type { Notification, NotificationAction } from "$lib/types"

const notificationBusName = "org.freedesktop.Notifications"
const notificationObjectPath = "/org/freedesktop/Notifications"
const notificationInterfaceName = "org.freedesktop.Notifications"
const specificationVersion = "1.3"
const maximumNotificationId = 0xffffffff
const defaultVisualNotificationTimeout = 8000
type NotificationHints = Record<string, Variant>
type NotificationListener = (notifications: Notification[]) => void

type NotificationHandlers = {
	notify: (
		appName: string,
		replacesId: number,
		appIcon: string,
		summary: string,
		body: string,
		actions: string[],
		hints: NotificationHints,
		expireTimeout: number,
	) => number
	close: (id: number) => void
}

const { Interface } = dbus.interface

class NotificationDbusInterface extends Interface {
	constructor(private readonly handlers: NotificationHandlers) {
		super(notificationInterfaceName)
		this.$methods = NotificationDbusInterface.prototype.$methods
		this.$signals = NotificationDbusInterface.prototype.$signals
	}

	GetCapabilities(): string[] {
		return ["actions", "body"]
	}

	Notify(
		appName: string,
		replacesId: number,
		appIcon: string,
		summary: string,
		body: string,
		actions: string[],
		hints: NotificationHints,
		expireTimeout: number,
	): number {
		return this.handlers.notify(
			appName,
			replacesId,
			appIcon,
			summary,
			body,
			actions,
			hints,
			expireTimeout,
		)
	}

	CloseNotification(id: number): void {
		this.handlers.close(id)
	}

	GetServerInformation(): [string, string, string, string] {
		return ["YAWSF", "bitbloxhub", "0.0.1", specificationVersion]
	}

	NotificationClosed(id: number, reason: number): [number, number] {
		return [id, reason]
	}

	ActionInvoked(id: number, actionId: string): [number, string] {
		return [id, actionId]
	}
}

NotificationDbusInterface.configureMembers({
	methods: {
		GetCapabilities: { inSignature: "", outSignature: "as" },
		Notify: { inSignature: "susssasa{sv}i", outSignature: "u" },
		CloseNotification: { inSignature: "u", outSignature: "" },
		GetServerInformation: { inSignature: "", outSignature: "ssss" },
	},
	signals: {
		NotificationClosed: { signature: "uu" },
		ActionInvoked: { signature: "us" },
	},
})

export interface NotificationService {
	notifications(): Notification[]
	subscribe(listener: NotificationListener): () => void
	dismiss(id: number): boolean
	invokeAction(id: number, actionId: string): boolean
	setPaused(id: number, paused: boolean): boolean
	available(): boolean
	stop(): Promise<void>
}

export async function startNotifications(): Promise<NotificationService> {
	const listeners = new Set<NotificationListener>()
	const entries = new Map<number, Notification>()
	const expiredEntries = new Set<number>()
	const timers = new Map<number, ReturnType<typeof setTimeout>>()
	const pausedTimeouts = new Map<number, number>()
	let bus: MessageBus | null = null
	let dbusInterface: NotificationDbusInterface | null = null
	let ownsName = false
	let stopped = false
	let nextId = 1

	const snapshotEntries = (source: Iterable<Notification>): Notification[] =>
		[...source]
			.sort((left, right) => right.receivedAt - left.receivedAt)
			.map((notification) => ({
				...notification,
				actions: notification.actions.map((action) => ({ ...action })),
			}))

	const snapshot = (): Notification[] =>
		snapshotEntries(
			[...entries]
				.filter(([id]) => !expiredEntries.has(id))
				.map(([, notification]) => notification),
		)

	const notifyListeners = () => {
		const current = snapshot()
		for (const listener of listeners) {
			try {
				listener(current)
			} catch (error) {
				console.warn("notification listener failed", error)
			}
		}
	}

	const clearExpiration = (id: number) => {
		const timer = timers.get(id)
		if (!timer) return
		clearTimeout(timer)
		timers.delete(id)
	}

	const scheduleExpiration = (id: number, timeout: number) => {
		timers.set(
			id,
			setTimeout(() => {
				if (!entries.has(id)) return
				expiredEntries.add(id)
				clearExpiration(id)
				notifyListeners()
			}, timeout),
		)
	}

	const close = (id: number, reason: number): boolean => {
		if (!entries.delete(id)) return false
		expiredEntries.delete(id)
		pausedTimeouts.delete(id)
		clearExpiration(id)

		try {
			dbusInterface?.NotificationClosed(id, reason)
		} catch (error) {
			console.warn("failed to emit NotificationClosed", error)
		}

		notifyListeners()
		return true
	}

	const nextNotificationId = (): number => {
		for (let attempt = 0; attempt < maximumNotificationId; attempt += 1) {
			const id = nextId
			nextId = nextId === maximumNotificationId ? 1 : nextId + 1
			if (!entries.has(id)) return id
		}

		throw new dbus.DBusError(
			"org.freedesktop.Notifications.Error",
			"No notification IDs are available",
		)
	}

	const addNotification = (
		appName: string,
		replacesId: number,
		appIcon: string,
		summary: string,
		body: string,
		actions: string[],
		hints: NotificationHints,
		expireTimeout: number,
	): number => {
		if (actions.length % 2 !== 0) {
			throw new dbus.DBusError(
				"org.freedesktop.Notifications.Error",
				"Notification actions must contain identifier and label pairs",
			)
		}

		const id = replacesId > 0 && entries.has(replacesId) ? replacesId : nextNotificationId()
		expiredEntries.delete(id)
		clearExpiration(id)
		pausedTimeouts.delete(id)
		const receivedAt = Date.now()
		const timeout = expireTimeout > 0 ? expireTimeout : 0
		const visualTimeout =
			expireTimeout === 0
				? 0
				: expireTimeout > 0
					? expireTimeout
					: defaultVisualNotificationTimeout
		const expiresAt = timeout > 0 ? receivedAt + timeout : null
		const visualExpiresAt = visualTimeout > 0 ? receivedAt + visualTimeout : null
		const notification: Notification = {
			id,
			appName,
			appIcon: mediaAssetUrl(appIcon),
			summary,
			body,
			actions: toActions(actions),
			urgency: urgencyValue(hints.urgency),
			category: stringValue(hints.category),
			resident: booleanValue(hints.resident),
			transient: booleanValue(hints.transient),
			receivedAt,
			expiresAt,
			visualExpiresAt,
		}
		entries.set(id, notification)
		if (timeout > 0) scheduleExpiration(id, timeout)
		notifyListeners()
		return id
	}

	const setPaused = (id: number, paused: boolean): boolean => {
		const notification = entries.get(id)
		if (!notification || notification.expiresAt === null) return false

		if (paused) {
			if (pausedTimeouts.has(id)) return true

			const remaining = Math.max(0, notification.expiresAt - Date.now())
			if (remaining === 0) {
				expiredEntries.add(id)
				clearExpiration(id)
				notifyListeners()
				return false
			}

			clearExpiration(id)
			pausedTimeouts.set(id, remaining)
			const expiresAt = Date.now() + remaining
			entries.set(id, { ...notification, expiresAt, visualExpiresAt: expiresAt })
			notifyListeners()
			return true
		}

		const remaining = pausedTimeouts.get(id)
		if (remaining === undefined) return true

		pausedTimeouts.delete(id)
		const expiresAt = Date.now() + remaining
		entries.set(id, { ...notification, expiresAt, visualExpiresAt: expiresAt })
		scheduleExpiration(id, remaining)
		notifyListeners()
		return true
	}

	const closeFromDbus = (id: number) => {
		if (close(id, 3)) return
		throw new dbus.DBusError(
			"org.freedesktop.Notifications.Error",
			`Notification ${id} does not exist`,
		)
	}

	const invokeAction = (id: number, actionId: string): boolean => {
		const notification = entries.get(id)
		if (!notification || !notification.actions.some((action) => action.id === actionId))
			return false

		try {
			dbusInterface?.ActionInvoked(id, actionId)
		} catch (error) {
			console.warn("failed to emit ActionInvoked", error)
		}

		if (!notification.resident) close(id, 2)
		return true
	}

	try {
		bus = dbus.sessionBus()
		const result = await bus.requestName(notificationBusName, dbus.NameFlag.DO_NOT_QUEUE)
		if (
			result !== dbus.RequestNameReply.PRIMARY_OWNER &&
			result !== dbus.RequestNameReply.ALREADY_OWNER
		) {
			throw new Error(`D-Bus name is already owned: ${notificationBusName}`)
		}

		const handlers: NotificationHandlers = {
			notify: addNotification,
			close: closeFromDbus,
		}
		dbusInterface = new NotificationDbusInterface(handlers)
		bus.export(notificationObjectPath, dbusInterface)
		ownsName = true
	} catch (error) {
		console.warn("Notifications unavailable", error)
		bus?.disconnect()
		bus = null
	}

	return {
		notifications: snapshot,
		subscribe(listener) {
			listeners.add(listener)
			listener(snapshot())
			return () => listeners.delete(listener)
		},
		dismiss(id) {
			return close(id, 2)
		},
		invokeAction,
		setPaused,
		available: () => ownsName,
		async stop() {
			if (stopped) return
			stopped = true
			for (const id of timers.keys()) clearExpiration(id)
			pausedTimeouts.clear()
			entries.clear()
			listeners.clear()

			if (bus) {
				try {
					if (dbusInterface) bus.unexport(notificationObjectPath, dbusInterface)
					if (ownsName) await bus.releaseName(notificationBusName)
				} catch (error) {
					console.warn("failed to release notification D-Bus service", error)
				} finally {
					bus.disconnect()
				}
			}
		},
	}
}

function toActions(values: string[]): NotificationAction[] {
	const actions: NotificationAction[] = []
	for (let index = 0; index < values.length; index += 2) {
		actions.push({ id: values[index], label: values[index + 1] })
	}
	return actions
}

function unwrap(value: unknown): unknown {
	if (value && typeof value === "object" && "value" in value) {
		return unwrap((value as Variant).value)
	}
	return value
}

function stringValue(value: unknown): string {
	const unwrapped = unwrap(value)
	return typeof unwrapped === "string" ? unwrapped : ""
}

function booleanValue(value: unknown): boolean {
	return unwrap(value) === true
}

function urgencyValue(value: unknown): number {
	const unwrapped = unwrap(value)
	const number =
		typeof unwrapped === "number"
			? unwrapped
			: typeof unwrapped === "bigint"
				? Number(unwrapped)
				: 1
	return Math.max(0, Math.min(2, Math.trunc(number)))
}
