import { Accessor, createBinding, Setter } from "ags"
import { Gtk } from "ags/gtk4"
import NotificationsGObject from "../../utils/notifications"

export default function ControlCenter({
	notifications,
	showingControlCenter,
	setShowingControlCenter,
}: {
	notifications: NotificationsGObject
	showingControlCenter: Accessor<boolean>
	setShowingControlCenter: Setter<boolean>
}) {
	const notificationsLengthString = createBinding(
		notifications.notifd,
		"notifications",
	).as((ns) => ns.length.toString())

	return (
		<button
			onClicked={() => {
				setShowingControlCenter(!showingControlCenter.get())
			}}
		>
			<box orientation={Gtk.Orientation.HORIZONTAL} spacing={6}>
				<image iconName="tabler-bell-symbolic" pixelSize={20} />
				<label label={notificationsLengthString} />
			</box>
		</button>
	)
}
