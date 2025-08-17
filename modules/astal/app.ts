import { createState } from "ags"
import app from "ags/gtk4/app"
import GLib from "gi://GLib?version=2.0"
import style from "./style.css"
import NiriGObject from "./utils/niri"
import NotificationsGObject from "./utils/notifications"
import Bar from "./widgets/bar"
import ControlCenter from "./widgets/control_center"
import Notifications from "./widgets/notifications"
import Launcher from "./widgets/launcher"
import Osd from "./widgets/osd"

app.start({
	css: style,
	icons: `${GLib.get_user_data_dir()}/astal-shell/icons`,
	main() {
		const niri = new NiriGObject()
		const notifications = new NotificationsGObject()
		const [showingControlCenter, setShowingControlCenter] =
			createState(false)

		app.get_monitors().map((monitor) => {
			Bar({
				monitor,
				niri,
				notifications,
				showingControlCenter,
				setShowingControlCenter,
			})
		})

		ControlCenter({
			niri,
			notifications,
			showingControlCenter,
			setShowingControlCenter,
		})

		Notifications({
			niri,
			notifications,
			showingControlCenter,
		})

		Launcher()

		Osd({
			niri,
		})
	},
})
