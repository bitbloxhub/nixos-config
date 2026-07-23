import type { NiriService } from "./niri"
import { createYawsfHostClient, type YawsfHostClient } from "$lib/server/yawsf-host-client"
import { deleteLayerShellWindow, updateLayerShellWindow } from "$lib/server/yawsf-host/sdk.gen"

interface HostInfo {
	host_api: string
	token: string
}

export interface TopbarService {
	stop(): Promise<void>
}

export function startTopbars(info: HostInfo, shellUrl: string, niri: NiriService): TopbarService {
	const bars = new Map<string, boolean>()
	const client = createYawsfHostClient(info)
	let reconciliation = Promise.resolve()
	let overviewOpen = false
	const unsubscribe = niri.subscribe((event) => {
		if (event.OverviewOpenedOrClosed) overviewOpen = event.OverviewOpenedOrClosed.is_open
		if (!event.OverviewOpenedOrClosed && !event.WorkspacesChanged) return
		reconciliation = reconciliation.then(() =>
			reconcileBars(client, shellUrl, bars, niri.outputs(), overviewOpen),
		)
	})

	// Niri may have emitted its initial WorkspacesChanged event before subscription.
	// Reconcile now so existing outputs get hidden bars pre-created at startup.
	reconciliation = reconciliation.then(() =>
		reconcileBars(client, shellUrl, bars, niri.outputs(), overviewOpen),
	)

	return {
		async stop() {
			unsubscribe()
			await reconciliation
			await Promise.allSettled([...bars.keys()].map((monitor) => closeBar(client, monitor)))
		},
	}
}

async function reconcileBars(
	client: YawsfHostClient,
	shellUrl: string,
	bars: Map<string, boolean>,
	outputs: string[],
	visible: boolean,
): Promise<void> {
	const activeMonitors = new Set(outputs)

	for (const monitor of outputs) {
		if (bars.get(monitor) === visible) continue
		try {
			await upsertBar(client, shellUrl, monitor, visible)
			bars.set(monitor, visible)
		} catch (error) {
			console.warn("failed to upsert bar", error)
		}
	}

	for (const monitor of bars.keys()) {
		if (activeMonitors.has(monitor)) continue
		try {
			await closeBar(client, monitor)
			bars.delete(monitor)
		} catch (error) {
			console.warn("failed to close bar", error)
		}
	}
}

async function upsertBar(
	client: YawsfHostClient,
	shellUrl: string,
	monitor: string,
	visible: boolean,
): Promise<void> {
	const id = `topbar-${monitor}`
	await updateLayerShellWindow({
		body: {
			url: new URL("/topbar", shellUrl).toString(),
			namespace: "topbar",
			layer: "top",
			anchors: { top: true, left: true, right: true, bottom: false },
			exclusiveZone: { mode: "none" },
			margins: { top: 0, bottom: 0, left: 0, right: 0 },
			keyboardMode: "none",
			width: null,
			height: 31,
			monitor,
			visible,
		},
		client,
		path: { id },
		throwOnError: true,
	})
}

async function closeBar(client: YawsfHostClient, monitor: string): Promise<void> {
	await deleteLayerShellWindow({
		client,
		path: { id: `topbar-${monitor}` },
		throwOnError: true,
	})
}
