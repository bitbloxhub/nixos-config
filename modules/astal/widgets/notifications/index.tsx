import { createComputed, createState, For } from "ags"
import Notifd from "gi://AstalNotifd"
import Niri from "../../utils/niri"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import Notification from "./notification"

export default function Notifications() {
	const niri = new Niri()
	const notifd = Notifd.get_default()
	const { TOP, RIGHT } = Astal.WindowAnchor
	const [window, setWindow] = createState<Astal.Window | null>(null)
	const [notifications, setNotifications] = createState(
		new Array<Notifd.Notification>(),
	)
	const [hiddenNotificationIDs, setHiddenNotificationIDs] = createState(
		new Array<number>(),
	)
	const shownNotifications = createComputed(
		[notifications, hiddenNotificationIDs],
		() => {
			return notifications.get().filter((n) => {
				return !hiddenNotificationIDs.get().includes(n.id)
			})
		},
	)
	const visible = shownNotifications(() => {
		return shownNotifications.get().length != 0
	})
	visible(() => {
		if (visible.get()) {
		}
	})

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
		setCurrentMonitor(
			monitors[
				niri.workspaces.find((workspace) => {
					return (workspace.id = id)
				})?.output || "never"
			],
		)
	})

	notifd.connect("notified", (_, id, replaced) => {
		const notification = notifd.get_notification(id)

		if (replaced) {
			setNotifications((ns) =>
				ns.map((n) => (n.id === id ? notification : n)),
			)
		} else {
			setNotifications((ns) => [notification, ...ns])
		}
	})

	notifd.connect("resolved", (_, id) => {
		setNotifications((ns) => ns.filter((n) => n.id !== id))
	})

	return (
		<window
			$={(self) => {
				setWindow(self)
			}}
			visible={visible}
			name="notifications"
			gdkmonitor={currentMonitor}
			exclusivity={Astal.Exclusivity.NORMAL}
			keymode={Astal.Keymode.ON_DEMAND}
			anchor={TOP | RIGHT}
			application={app}
		>
			<box orientation={Gtk.Orientation.VERTICAL}>
				<For each={shownNotifications}>
					{(notification) => (
						<Notification
							notification={notification}
							onHide={() => {
								setHiddenNotificationIDs((ids) => {
									return ids.concat(notification.id)
								})
							}}
							onRemove={() => {
								setNotifications((ns) => {
									return ns.filter((n) => {
										return n.id != notification.id
									})
								})
							}}
						/>
					)}
				</For>
			</box>
		</window>
	)
}
