import { createBinding, For } from "ags"
import { Gtk } from "ags/gtk4"
import AstalWp from "gi://AstalWp?version=0.1"

export default function Audio() {
	const wp = AstalWp.get_default()
	const audio = wp.audio

	return (
		<box orientation={Gtk.Orientation.VERTICAL}>
			<For each={createBinding(audio, "speakers")}>
				{(speaker: AstalWp.Endpoint) => {
					return (
						<box
							orientation={Gtk.Orientation.HORIZONTAL}
							class="audio_volume_box"
						>
							<image
								iconName={createBinding(speaker, "volume_icon")}
							/>
							<slider
								$={(self) => {
									speaker.connect("notify::volume", () => {
										self.value = speaker.volume
									})
								}}
								hexpand
								step={0.05}
								value={speaker.volume}
								onValueChanged={({ value }) => {
									speaker.volume = value
								}}
							/>
						</box>
					)
				}}
			</For>
		</box>
	)
}
