import { createConnection } from "node:net"

import type { NiriWorkspace } from "$lib/types"

export type NiriEvent = {
	WorkspacesChanged?: { workspaces: NiriWorkspace[] }
	WorkspaceActivated?: { focused: boolean; id: number }
	OverviewOpenedOrClosed?: { is_open: boolean }
	[key: string]: unknown
}

type NiriListener = (event: NiriEvent) => void

export interface NiriService {
	outputs(): string[]
	workspaces(): NiriWorkspace[]
	subscribe(listener: NiriListener): () => void
	focusWorkspace(index: number): Promise<void>
	stop(): Promise<void>
}

export async function startNiri(): Promise<NiriService> {
	const socketPath = process.env.NIRI_SOCKET
	const listeners = new Set<NiriListener>()
	const outputs = new Set<string>()
	let workspaces: NiriWorkspace[] = []
	let socket: ReturnType<typeof createConnection> | null = null
	let reconnectTimer: ReturnType<typeof setTimeout> | null = null
	let stopped = false
	let buffer = ""

	const currentOutputs = () => [...outputs].sort()
	const currentWorkspaces = () => [...workspaces].sort((left, right) => left.idx - right.idx)
	const notify = (event: NiriEvent) => {
		for (const listener of listeners) listener(event)
	}

	const applyEvent = (event: NiriEvent) => {
		if (event.WorkspacesChanged) {
			workspaces = event.WorkspacesChanged.workspaces
			outputs.clear()
			for (const workspace of workspaces) if (workspace.output) outputs.add(workspace.output)
			notify(event)
			return
		}

		const workspaceActivated = event.WorkspaceActivated
		if (workspaceActivated) {
			const activated = workspaces.find((workspace) => workspace.id === workspaceActivated.id)
			if (activated) {
				workspaces = workspaces.map((workspace) => ({
					...workspace,
					is_active:
						workspace.output === activated.output
							? workspace.id === activated.id
							: workspace.is_active,
					is_focused: workspaceActivated.focused
						? workspace.id === activated.id
						: workspace.is_focused,
				}))
			}
		}
		notify(event)
	}

	const scheduleReconnect = () => {
		if (stopped || reconnectTimer) return
		reconnectTimer = setTimeout(() => {
			reconnectTimer = null
			connect()
		}, 1000)
	}

	const connect = () => {
		if (!socketPath || stopped) return
		buffer = ""
		socket = createConnection(socketPath)
		socket.once("connect", () => socket?.write('"EventStream"\n'))
		socket.on("data", (chunk) => {
			buffer += chunk.toString()
			const lines = buffer.split("\n")
			buffer = lines.pop() ?? ""
			for (const line of lines) {
				try {
					applyEvent(JSON.parse(line) as NiriEvent)
				} catch {
					console.warn("ignored invalid niri IPC event")
				}
			}
		})
		socket.once("error", (error) => console.warn("niri event stream error", error))
		socket.once("close", scheduleReconnect)
	}

	if (socketPath) connect()

	return {
		outputs: currentOutputs,
		workspaces: currentWorkspaces,
		subscribe(listener) {
			listeners.add(listener)
			return () => listeners.delete(listener)
		},
		focusWorkspace(index) {
			if (!socketPath) return Promise.reject(new Error("NIRI_SOCKET is unavailable"))
			return sendRequest(socketPath, {
				Action: { FocusWorkspace: { reference: { Index: index } } },
			})
		},
		async stop() {
			stopped = true
			if (reconnectTimer) clearTimeout(reconnectTimer)
			listeners.clear()
			socket?.destroy()
		},
	}
}

function sendRequest(socketPath: string, request: unknown): Promise<void> {
	return new Promise((resolve, reject) => {
		const socket = createConnection(socketPath)
		let buffer = ""
		let settled = false
		const finish = (error?: Error) => {
			if (settled) return
			settled = true
			socket.destroy()
			if (error) reject(error)
			else resolve()
		}
		socket.once("connect", () => socket.write(`${JSON.stringify(request)}\n`))
		socket.on("data", (chunk) => {
			buffer += chunk.toString()
			const line = buffer.split("\n")[0]
			if (!line) return
			try {
				const response = JSON.parse(line) as { Err?: unknown }
				finish(response.Err ? new Error(JSON.stringify(response.Err)) : undefined)
			} catch (error) {
				finish(error instanceof Error ? error : new Error(String(error)))
			}
		})
		socket.once("error", (error) => finish(error))
	})
}
