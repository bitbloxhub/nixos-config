import { deleteLayerShellWindow, updateLayerShellWindow } from "$lib/server/yawsf-host/sdk.gen"
import { createYawsfHostClient } from "$lib/server/yawsf-host-client"
import type { NiriService } from "./niri"

const bentoWindowId = "yawsf-bento"

interface HostInfo {
	host_api: string
	token: string
}

export interface BentoWindowsService {
	open(): Promise<void>
	close(): Promise<void>
	toggle(): Promise<void>
	stop(): Promise<void>
}

export function startBentoWindows(
	info: HostInfo,
	shellUrl: string,
	niri: NiriService,
): BentoWindowsService {
	const client = createYawsfHostClient(info)
	let open = false
	let monitor: string | null = null
	let queue = Promise.resolve()
	let stopped = false

	const enqueue = (operation: () => Promise<void>) => {
		queue = queue.then(operation).catch((error) => {
			console.warn("failed to update bento window", error)
		})
		return queue
	}

	return {
		open: () =>
			enqueue(async () => {
				if (stopped || open) return
				monitor =
					niri.workspaces().find((workspace) => workspace.is_focused)?.output ?? null
				await updateLayerShellWindow({
					body: {
						url: new URL("/bento", shellUrl).toString(),
						namespace: bentoWindowId,
						layer: "overlay",
						anchors: { top: true, right: true, bottom: true, left: true },
						exclusiveZone: { mode: "none" },
						keyboardMode: "exclusive",
						width: null,
						height: null,
						monitor,
					},
					client,
					path: { id: bentoWindowId },
					throwOnError: true,
				})
				open = true
			}),
		close: () =>
			enqueue(async () => {
				if (!open) return
				await deleteLayerShellWindow({
					client,
					path: { id: bentoWindowId },
					throwOnError: true,
				})
				open = false
			}),
		toggle: () =>
			open
				? enqueue(async () => {
						await deleteLayerShellWindow({
							client,
							path: { id: bentoWindowId },
							throwOnError: true,
						})
						open = false
					})
				: enqueue(async () => {
						if (stopped) return
						monitor =
							niri.workspaces().find((workspace) => workspace.is_focused)?.output ??
							null
						await updateLayerShellWindow({
							body: {
								url: new URL("/bento", shellUrl).toString(),
								namespace: bentoWindowId,
								layer: "overlay",
								anchors: { top: true, right: true, bottom: true, left: true },
								exclusiveZone: { mode: "none" },
								keyboardMode: "exclusive",
								width: null,
								height: null,
								monitor,
							},
							client,
							path: { id: bentoWindowId },
							throwOnError: true,
						})
						open = true
					}),
		stop: () =>
			enqueue(async () => {
				stopped = true
				if (open)
					await deleteLayerShellWindow({
						client,
						path: { id: bentoWindowId },
						throwOnError: true,
					})
				open = false
			}),
	}
}
