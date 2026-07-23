import { deleteLayerShellWindow, updateLayerShellWindow } from "$lib/server/yawsf-host/sdk.gen"
import { createYawsfHostClient, type YawsfHostClient } from "$lib/server/yawsf-host-client"
import type { NiriService } from "./niri"
import type { NotificationService } from "./notifications"

const notificationWindowId = "yawsf-notifications"
const notificationExitDuration = 450

type HostInfo = {
	host_api: string
	token: string
}

export interface NotificationWindowsService {
	resize(height: number): Promise<void>
	stop(): Promise<void>
}

export function startNotificationWindows(
	info: HostInfo,
	shellUrl: string,
	niri: NiriService,
	notifications: NotificationService,
): NotificationWindowsService {
	const client = createYawsfHostClient(info)
	let queue = Promise.resolve()
	let stopped = false
	let open = false
	let monitor: string | null = null
	let closeTimer: ReturnType<typeof setTimeout> | null = null
	let windowHeight = 240

	const cancelCloseTimer = () => {
		if (!closeTimer) return
		clearTimeout(closeTimer)
		closeTimer = null
	}

	const enqueueReconciliation = () => {
		queue = queue.then(reconcile).catch((error) => {
			console.warn("failed to reconcile notification window", error)
		})
	}

	const enqueueClose = (force = false) => {
		queue = queue
			.then(async () => {
				if (stopped || (!force && notifications.notifications().length > 0) || !open) return
				await closeWindow(client)
				open = false
				monitor = null
			})
			.catch((error) => {
				console.warn("failed to close notification window", error)
			})
	}

	const scheduleClose = () => {
		if (closeTimer || !open) return
		closeTimer = setTimeout(() => {
			closeTimer = null
			enqueueClose()
		}, notificationExitDuration)
	}

	const enqueueResize = () => {
		queue = queue
			.then(async () => {
				if (stopped || !open) return
				await updateWindow(client, shellUrl, monitor, windowHeight, true)
			})
			.catch((error) => {
				console.warn("failed to resize notification window", error)
			})
	}

	const unsubscribeNotifications = notifications.subscribe(enqueueReconciliation)
	const unsubscribeNiri = niri.subscribe(enqueueReconciliation)
	enqueueReconciliation()

	return {
		resize(height) {
			const nextHeight = Math.max(0, Math.ceil(height))
			if (!Number.isFinite(nextHeight) || nextHeight === windowHeight) return queue

			windowHeight = nextHeight
			if (open) {
				if (nextHeight === 0) enqueueClose(true)
				else enqueueResize()
			}
			return queue
		},
		async stop() {
			stopped = true
			cancelCloseTimer()
			unsubscribeNotifications()
			unsubscribeNiri()
			await queue
			if (!open) return

			try {
				await closeWindow(client)
			} catch (error) {
				console.warn("failed to close notification window", error)
			}
			open = false
		},
	}

	async function reconcile(): Promise<void> {
		if (stopped) return

		const hasNotifications = notifications.notifications().length > 0
		if (!hasNotifications) {
			scheduleClose()
			return
		}
		cancelCloseTimer()

		const nextMonitor = focusedMonitor(niri)
		if (open && monitor === nextMonitor) return

		await updateWindow(client, shellUrl, nextMonitor, windowHeight, true)
		open = true
		monitor = nextMonitor
	}
}

async function updateWindow(
	client: YawsfHostClient,
	shellUrl: string,
	monitor: string | null,
	height: number,
	visible: boolean,
): Promise<void> {
	await updateLayerShellWindow({
		body: {
			url: new URL("/notifications", shellUrl).toString(),
			namespace: "yawsf-notifications",
			layer: "overlay",
			anchors: { top: true, right: true, bottom: false },
			exclusiveZone: { mode: "none" },
			margins: { right: 0 },
			keyboardMode: "none",
			width: 420,
			height,
			monitor,
			visible,
		},
		client,
		path: { id: notificationWindowId },
		throwOnError: true,
	})
}

async function closeWindow(client: YawsfHostClient): Promise<void> {
	await deleteLayerShellWindow({
		client,
		path: { id: notificationWindowId },
		throwOnError: true,
	})
}

function focusedMonitor(niri: NiriService): string | null {
	return niri.workspaces().find((workspace) => workspace.is_focused)?.output ?? null
}
