import { createBinding, For } from "ags"
import { Gdk, Gtk } from "ags/gtk4"
import Adw from "gi://Adw?version=1"
import Notifd from "gi://AstalNotifd"
import AstalNotifd from "gi://AstalNotifd?version=0.1"
import Pango from "gi://Pango?version=1.0"

export default function Notification({
	notification,
	onRemove,
	maxWidth = 400,
}: {
	notification: Notifd.Notification
	onRemove: () => void
	maxWidth?: number
}) {
	return (
		<Adw.Clamp
			maximumSize={maxWidth}
			orientation={Gtk.Orientation.HORIZONTAL}
			tighteningThreshold={maxWidth}
		>
			<box class="notification" orientation={Gtk.Orientation.HORIZONTAL}>
				<image file={notification.image} pixelSize={48} />
				<box orientation={Gtk.Orientation.VERTICAL}>
					<box orientation={Gtk.Orientation.VERTICAL}>
						<box orientation={Gtk.Orientation.HORIZONTAL}>
							<label
								label={notification.appName}
								wrap
								wrapMode={Pango.WrapMode.WORD_CHAR}
								halign={Gtk.Align.START}
							/>
							<button
								halign={Gtk.Align.END}
								class="circular"
								iconName="tabler-x-symbolic"
								hexpand
							>
								<Gtk.GestureClick onPressed={onRemove} />
								<Gtk.EventControllerKey
									onKeyPressed={(_e, keyval) => {
										if (keyval != Gdk.KEY_Return) {
											return
										}
										onRemove()
									}}
								/>
							</button>
						</box>
						<label
							label={notification.summary}
							wrap
							wrapMode={Pango.WrapMode.WORD_CHAR}
							halign={Gtk.Align.START}
						/>
						<label
							label={notification.body}
							visible={notification.body != ""}
							wrap
							wrapMode={Pango.WrapMode.WORD_CHAR}
							halign={Gtk.Align.START}
						/>
					</box>
					<box orientation={Gtk.Orientation.HORIZONTAL}>
						<For each={createBinding(notification, "actions")}>
							{(action: AstalNotifd.Action) => {
								return (
									<button
										label={action.label}
										onClicked={() => {
											notification.invoke(action.id)
											notification.dismiss()
										}}
									/>
								)
							}}
						</For>
					</box>
				</box>
			</box>
		</Adw.Clamp>
	)
}
