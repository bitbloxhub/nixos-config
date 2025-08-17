import { Gtk } from "ags/gtk4"
import { Accessor } from "ags"
import { createPoll } from "ags/time"
import GLib from "gi://GLib?version=2.0"

export default function Clock({
	timezone = "UTC",
	format = "%F %H:%M %Z",
	visible = true,
}: {
	timezone?: string | Accessor<string>
	format?: string
	visible?: boolean | Accessor<boolean>
}) {
	const time = createPoll("", 1000, () => {
		if (typeof timezone == "string") {
			return GLib.DateTime.new_now(
				GLib.TimeZone.new_identifier(timezone),
			).format(format)!
		} else {
			return GLib.DateTime.new_now(
				GLib.TimeZone.new_identifier(timezone.get().trim()),
			).format(format)!
		}
	})

	return (
		<menubutton visible={visible}>
			<label label={time} />
			<popover>
				<Gtk.Calendar />
			</popover>
		</menubutton>
	)
}
