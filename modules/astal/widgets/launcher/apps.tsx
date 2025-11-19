import AstalApps from "gi://AstalApps?version=0.1"
import { LauncherItemProvider } from "."
import { Astal, Gtk } from "ags/gtk4"
import Pango from "gi://Pango?version=1.0"
import { action } from "../../utils/niri"

export default class AppsProvider implements LauncherItemProvider {
	apps: AstalApps.Apps = new AstalApps.Apps()
	getItems({
		window,
		entry,
		search,
	}: {
		window: Astal.Window
		entry: Gtk.Entry
		search: (_: string) => void
	}) {
		return this.apps.list.map((app) => {
			return {
				rendered: (
					<button
						onClicked={() => {
							window.visible = false
							entry.text = ""
							search("")
							action("spawn-sh", "--", app.executable.replace(/%[fFcuUik]/g, ""))
						}}
					>
						<box
							orientation={Gtk.Orientation.HORIZONTAL}
							spacing={4}
						>
							<image
								iconName={app.icon_name}
								iconSize={Gtk.IconSize.LARGE}
							/>
							<box orientation={Gtk.Orientation.VERTICAL}>
								<label
									label={app.name}
									class="app_name"
									halign={Gtk.Align.START}
								/>
								<label
									label={app.description}
									class="app_description"
									halign={Gtk.Align.START}
									wrap
									wrapMode={Pango.WrapMode.WORD_CHAR}
								/>
							</box>
						</box>
					</button>
				) as Gtk.Button,
				searchTerm: app.name,
			}
		})
	}
}
