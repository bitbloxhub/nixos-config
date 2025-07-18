import { createState } from "ags"
import Notifd from "gi://AstalNotifd"
import Niri from "../../utils/niri"
import { Astal, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import Workspaces from "../bar/workspaces"

export default function Notifications() {
	const niri = new Niri()
	const notifd = Notifd.get_default()
	const { BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

	const display = Gdk.Display.get_default()
	if (display == null) {
		throw "No Gdk.Display!"
	}

	const monitors = Object.fromEntries(
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

	const [currentMonitor, setCurrentMonitor] = createState(
		monitors[
			niri.workspaces.find((workspace) => {
				return workspace.is_focused
			})?.output || "never"
		],
	)
	niri.connect("focus-changed", (_, id) => {
		console.log(id)
		setCurrentMonitor(monitors[niri.workspaces.find((workspace) => {
			return workspace.id = id 
		})?.output || "never"])
	})

	notifd.connect("notified", (_, id) => {
		const n = notifd.get_notification(id)
		console.log(n.body, n.summary)
	})

	return (
		<window
			visible
			gdkmonitor={currentMonitor}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			anchor={BOTTOM | LEFT | RIGHT}
			application={app}
		>
			<label label={"aaaa"} />
		</window>
	)
}
