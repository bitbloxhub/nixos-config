import { Gtk } from "ags/gtk4"
import NotificationsGObject from "../../utils/notifications"
import { createBinding, For } from "ags"
import AstalNotifd from "gi://AstalNotifd?version=0.1"
import Notification from "../../components/Notification"
import Adw from "gi://Adw?version=1"

export default function Notifications({
	notifications,
}: {
	notifications: NotificationsGObject
}) {
	const showPlaceholder = createBinding(
		notifications,
		"notifications",
	)(() => {
		return notifications.notifications.length == 0
	})
	return (
		<box orientation={Gtk.Orientation.VERTICAL}>
			<image
				iconName="preferences-system-notifications-symbolic"
				pixelSize={96}
				visible={showPlaceholder}
			/>
			<label
				label="No notifications!"
				visible={showPlaceholder}
				halign={Gtk.Align.CENTER}
			/>
			<Adw.Clamp
				maximumSize={600}
				orientation={Gtk.Orientation.VERTICAL}
				tighteningThreshold={600}
			>
				<scrolledwindow
					visible={showPlaceholder(() => !showPlaceholder.get())}
					propagateNaturalHeight
					propagateNaturalWidth
				>
					<box orientation={Gtk.Orientation.VERTICAL}>
						<For
							each={createBinding(notifications, "notifications")}
							id={(n) => {
								return n.id
							}}
						>
							{(notification: AstalNotifd.Notification) => {
								let onRemove = () => {
									notification.dismiss()
								}
								notification.connect("resolved", () => {
									revealer.reveal_child = false
								})
								const revealer = (
									<revealer
										$={(self) => {
											setTimeout(() => {
												self.reveal_child = true
											}, 100)
										}}
										transitionDuration={300}
										transitionType={
											Gtk.RevealerTransitionType
												.SLIDE_DOWN
										}
									>
										<Notification
											notification={notification}
											onHide={onRemove}
											onRemove={onRemove}
											maxWidth={500}
										/>
									</revealer>
								) as Gtk.Revealer
								return revealer
							}}
						</For>
					</box>
				</scrolledwindow>
			</Adw.Clamp>
		</box>
	)
}
