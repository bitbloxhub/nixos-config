import { Gdk, Gtk } from "ags/gtk4"
import Notifd from "gi://AstalNotifd?version=0.1"

export default function Notification({
	notification,
	onHide,
	onRemove,
}: {
	notification: Notifd.Notification
	onHide: () => void
	onRemove: () => void
}) {
	return (
		<box
			class="notification"
			orientation={Gtk.Orientation.HORIZONTAL}
			focusable={true}
		>
			<Gtk.GestureClick
				onPressed={(gesture) => {
					if (
						gesture.get_current_event_state() &
						Gdk.ModifierType.CONTROL_MASK
					) {
						onRemove()
					} else {
						onHide()
					}
				}}
			/>
			<Gtk.EventControllerKey
				onKeyPressed={(_e, keyval, _, mask) => {
					if (keyval == Gdk.KEY_Return) {
						if (mask == Gdk.ModifierType.SHIFT_MASK) {
							onRemove()
						} else {
							onHide()
						}
					}
				}}
			/>
			<image file={notification.image} pixel_size={48} />
			<box orientation={Gtk.Orientation.VERTICAL}>
				<label label={notification.appName} />
				<label label={notification.summary} />
				<label label={notification.body} />
			</box>
		</box>
	)
}
