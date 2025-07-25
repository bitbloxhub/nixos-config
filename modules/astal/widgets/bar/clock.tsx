import { Gtk } from "ags/gtk4"
import { Accessor } from "ags"
import { createPoll } from "ags/time"
import GLib from "gi://GLib?version=2.0"

export default function Clock({ timezone = "UTC", format = "%F %H:%M %Z" }) {
	const time = createPoll("", 1000, () => {
		return GLib.DateTime.new_now(
			GLib.TimeZone.new_identifier(timezone),
		).format(format)!
	})

	return (
		<menubutton>
			<label label={time} />
			<popover>
				<Gtk.Calendar />
			</popover>
		</menubutton>
	)
}
