import app from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"
import { Accessor } from "ags"
import Workspaces from "./workspaces"
import Clock from "./clock"
import Mpris from "./mpris"

export default function Bar(gdkmonitor: Gdk.Monitor) {
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

	return (
		<window
			visible
			name="bar"
			class="Bar"
			gdkmonitor={gdkmonitor}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			anchor={TOP | LEFT | RIGHT}
			application={app}
		>
			<centerbox>
				<box $type="start" spacing={12}>
					<Workspaces />
				</box>
				<box $type="center" spacing={12}>
					<Clock />
					<Mpris />
				</box>
				<box $type="end" spacing={12}></box>
			</centerbox>
		</window>
	)
}
