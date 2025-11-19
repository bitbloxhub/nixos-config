// Niri support
// Adapted from https://github.com/calops/nix/blob/7b343c3/modules/home/programs/ags/config/widget/services/niri.tsx
// Types adapted from https://github.com/YaLTeR/niri/blob/9c09bc7/niri-ipc/src/lib.rs

import GObject, { register, property, signal } from "ags/gobject"
import { Gdk } from "ags/gtk4"
import { exec, execAsync, subprocess } from "ags/process"

export interface Mode {
	width: number
	height: number
	refresh_rate: number
	is_preferred: boolean
}

export interface LogicalOutput {
	x: number
	y: number
	width: number
	height: number
	scale: number
}

export interface Output {
	name: string
	make: string
	model: string
	serial?: string
	physical_size?: [number, number]
	modes: Mode[]
	current_mode?: number
	vrr_supported: boolean
	vrr_enabled: boolean
	logical?: LogicalOutput
}

export interface Workspace {
	id: number
	idx: number
	name?: string
	output: string
	is_urgent: boolean
	is_active: boolean
	is_focused: boolean
	active_window_id?: number
}

export interface Window {
	id: number
	title?: string
	app_id?: string
	pid?: number
	workspace_id: number
	is_focused: boolean
	is_floating: boolean
	is_urgent: boolean
}

interface NiriSignals extends GObject.Object.SignalSignatures {
	"focus-changed": NiriGObject["focusChanged"]
}

export function action(...args: string[]) {
	return execAsync(["niri", "msg", "action", ...args])
}

@register({ GTypeName: "Niri" })
export default class NiriGObject extends GObject.Object {
	private _focusedWorkspace: number = 0

	@property(Number)
	focusedWindow: number = 1

	@property(Array<Window>)
	windows: Array<Window> = []

	@property(Array<Workspace>)
	workspaces: Array<Workspace> = []

	@property(Array<Output>)
	outputs: Array<Output> = []

	monitors: Record<string, Gdk.Monitor>

	@property(Gdk.Monitor)
	currentMonitor: Gdk.Monitor

	@signal([Number], GObject.TYPE_NONE, { default: false })
	focusChanged(this: object, _: number): undefined {
		throw "never runs!"
	}

	declare $signals: NiriSignals // this makes signals inferable in JSX

	override connect<S extends keyof NiriSignals>(
		signal: S,
		callback: GObject.SignalCallback<this, NiriSignals[S]>,
	): number {
		return super.connect(signal, callback)
	}

	constructor() {
		super()
		this.windows = JSON.parse(exec(["niri", "msg", "--json", "windows"]))
		this.workspaces = JSON.parse(
			exec(["niri", "msg", "--json", "workspaces"]),
		)
		this.outputs = JSON.parse(exec(["niri", "msg", "--json", "outputs"]))

		const display = Gdk.Display.get_default()
		if (display == null) {
			throw "No Gdk.Display!"
		}

		this.monitors = Object.fromEntries(
			Array.apply(null, Array(display.get_monitors().get_n_items())).map(
				(_, idx): [string, Gdk.Monitor] => {
					const monitor = display
						.get_monitors()
						.get_item(idx) as Gdk.Monitor
					const connector = monitor.connector
					return [connector, monitor]
				},
			),
		)

		this.currentMonitor =
			this.monitors[
				this.workspaces.find((workspace) => {
					return workspace.is_focused
				})?.output || "never"
			]

		this.connect("focus-changed", (_, id) => {
			this.currentMonitor =
				this.monitors[
					this.workspaces.find((workspace) => {
						return workspace.id == id
					})?.output || "never"
				]
		})

		subprocess(
			["niri", "msg", "--json", "event-stream"],
			(event) => this.handleEvent(JSON.parse(event)),
			(err) => console.error(err),
		)
	}

	handleEvent(event: any) {
		for (const key in event) {
			const value = event[key]
			switch (key) {
				case "WorkspacesChanged":
					this.onWorkspacesChanged(value.workspaces)
					break

				case "WindowsChanged":
					this.onWindowsChanged(value.windows)
					break

				case "WindowOpenedOrChanged":
					this.onWindowChanged(value.window)
					break

				case "WindowClosed":
					this.onWindowClosed(value.id)
					break

				case "WindowFocusChanged":
					this.focusedWindow = value.id
					break

				case "WorkspaceActivated":
					this.onWorkspaceFocused(value.id)
					break
			}
		}
	}

	onWorkspacesChanged(workspaces: Workspace[]) {
		this.workspaces = workspaces
		const focusedWorkspace = this.workspaces.find(
			(workspace) => workspace.is_focused,
		)?.id!
		this._focusedWorkspace = focusedWorkspace
		this.focusChanged(this._focusedWorkspace)
	}

	onWindowsChanged(windows: Window[]) {
		this.windows = windows
		this.focusedWindow = this.windows.find(
			(window) => window.is_focused,
		)?.id!
	}

	onWindowChanged(window: Window) {
		const index = this.windows.findIndex((w) => w.id === window.id)
		if (index === -1) {
			this.windows.push(window)
		} else {
			this.windows[index] = window
		}
		this.notify("windows")
	}

	onWindowClosed(id: number) {
		this.windows.splice(
			this.windows.findIndex((w) => w.id === id),
			1,
		)
		this.notify("windows")
	}

	onWorkspaceFocused(workspaceId: number) {
		this.workspaces.find(
			(workspace) => workspace.id === this._focusedWorkspace,
		)!.is_focused = false
		this.workspaces.find((workspace) => {
			return workspace.id === workspaceId
		})!.is_focused = true
		this._focusedWorkspace = workspaceId
		this.focusChanged(workspaceId)
	}

	focusWorkspace(id: number) {
		action("focus-workspace", String(id)).then(() => {})
	}
}
