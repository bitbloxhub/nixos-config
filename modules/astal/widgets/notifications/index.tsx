import { Accessor, createBinding, createComputed, For } from "ags"
import { Astal, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import NiriGObject from "../../utils/niri"
import NotificationsGObject from "../../utils/notifications"
import Notification from "../../components/Notification"

export default function Notifications({
	niri,
	notifications,
	showingControlCenter,
}: {
	niri: NiriGObject
	notifications: NotificationsGObject
	showingControlCenter: Accessor<boolean>
}) {
	const { TOP, RIGHT } = Astal.WindowAnchor

	const shownNotifications = createComputed(
		[
			createBinding(notifications, "notifications"),
			createBinding(notifications, "hiddenNotificationIDs"),
		],
		() => {
			return notifications.notifd.notifications.filter((n) => {
				return !notifications.hiddenNotificationIDs.includes(n.id)
			})
		},
	)

	const visible = createComputed(
		[shownNotifications, showingControlCenter],
		() => {
			if (showingControlCenter.get()) {
				return false
			} else {
				return shownNotifications.get().length != 0
			}
		},
	)

	return (
		<window
			defaultHeight={-1}
			defaultWidth={-1}
			visible={visible}
			name="notifications"
			gdkmonitor={createBinding(niri, "currentMonitor")}
			exclusivity={Astal.Exclusivity.NORMAL}
			keymode={Astal.Keymode.ON_DEMAND}
			anchor={TOP | RIGHT}
			application={app}
		>
			<box
				orientation={Gtk.Orientation.VERTICAL}
				class={"notificationbox"}
				hexpand
			>
				<For
					each={shownNotifications}
					id={(n) => {
						return n.id
					}}
				>
					{(notification) => {
						notification.connect("resolved", () => {
							revealer.reveal_child = false
						})
						const revealer: Gtk.Revealer = (
							<revealer
								$={(self) => {
									setTimeout(() => {
										self.reveal_child = true
									}, 100)
								}}
								transitionDuration={300}
								transitionType={
									Gtk.RevealerTransitionType.SLIDE_LEFT
								}
							>
								<Notification
									notification={notification}
									onHide={() => {
										revealer.reveal_child = false
										setTimeout(() => {
											notifications.hiddenNotificationIDs =
												notifications.hiddenNotificationIDs.concat(
													notification.id,
												)
										}, 300)
									}}
									onRemove={() => {
										revealer.reveal_child = false
										notification.dismiss()
									}}
								/>
							</revealer>
						) as Gtk.Revealer

						return revealer
					}}
				</For>
			</box>
		</window>
	)
}
