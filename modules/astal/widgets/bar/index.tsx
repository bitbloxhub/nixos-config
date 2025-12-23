import { Accessor, createState, Setter } from "ags"
import { Astal, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import NiriGObject from "../../utils/niri"
import NotificationsGObject from "../../utils/notifications"
import Workspaces from "./workspaces"
import Clock from "./clock"
import Mpris from "./mpris"
import Cava from "./cava"
import ControlCenter from "./controlcenter"
import { monitorFile, readFile, writeFile } from "ags/file"
import GLib from "gi://GLib?version=2.0"

export default function Bar({
	monitor,
	niri,
	notifications,
	showingControlCenter,
	setShowingControlCenter,
}: {
	monitor: Gdk.Monitor
	niri: NiriGObject
	notifications: NotificationsGObject
	showingControlCenter: Accessor<boolean>
	setShowingControlCenter: Setter<boolean>
}) {
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
	const localTimeFile = `${GLib.get_user_config_dir()}/localtimezone`

	const [localTime, setLocalTime] = createState("UTC")

	if (GLib.file_test(localTimeFile, GLib.FileTest.EXISTS)) {
		setLocalTime(readFile(localTimeFile))
	} else {
		writeFile(localTimeFile, "UTC")
	}

	monitorFile(localTimeFile, async () => {
		setLocalTime(readFile(localTimeFile))
	})

	return (
		<window
			visible
			name="bar"
			class="Bar"
			gdkmonitor={monitor}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			anchor={TOP | LEFT | RIGHT}
			application={app}
		>
			<centerbox>
				<box $type="start" spacing={12}>
					<Workspaces niri={niri} />
				</box>
				<box $type="center" spacing={12}>
					<Clock />
					<Mpris />
					<Cava />
					<Clock
						timezone={localTime}
						format="%F %I:%M %p %Z"
						visible={localTime(() => localTime.peek() != "UTC")}
					/>
				</box>
				<box $type="end" spacing={12}>
					<ControlCenter
						notifications={notifications}
						showingControlCenter={showingControlCenter}
						setShowingControlCenter={setShowingControlCenter}
					/>
				</box>
			</centerbox>
		</window>
	)
}
