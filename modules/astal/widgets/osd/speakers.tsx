import { Accessor, createBinding, For, Setter } from "ags"
import AstalWp from "gi://AstalWp?version=0.1"
import GLib from "gi://GLib?version=2.0"
import { OsdWrapper } from "."

export default function Speakers({
	setCurrentOsd,
	setRevealOsd,
	timeoutSource,
	setTimeoutSource,
}: {
	setCurrentOsd: Setter<string>
	setRevealOsd: Setter<boolean>
	timeoutSource: Accessor<GLib.Source | null>
	setTimeoutSource: Setter<GLib.Source | null>
}) {
	const wp = AstalWp.get_default()
	const audio = wp.audio

	return (
		<For each={createBinding(audio, "speakers")}>
			{(speaker: AstalWp.Endpoint) => {
				speaker.connect("notify::mute", () => {
					setCurrentOsd(`speaker-${speaker.device.id}`)
					setRevealOsd(true)
					if (timeoutSource.get() != null) {
						clearTimeout(timeoutSource.get() as GLib.Source)
					}
					setTimeoutSource(
						setTimeout(() => {
							setRevealOsd(false)
						}, 2000),
					)
				})
				speaker.connect("notify::volume", () => {
					setCurrentOsd(`speaker-${speaker.device.id}`)
					setRevealOsd(true)
					if (timeoutSource.get() != null) {
						clearTimeout(timeoutSource.get() as GLib.Source)
					}
					setTimeoutSource(
						setTimeout(() => {
							setRevealOsd(false)
						}, 2000),
					)
				})

				return (
					<OsdWrapper
						type="speaker"
						id={createBinding(
							speaker,
							"device_id",
						)((id) => id.toString())}
						offsets={[
							{
								name: "low",
								value: 0.4,
							},
							{
								name: "medium",
								value: 0.7,
							},
							{
								name: "high",
								value: 1,
							},
						]}
						iconName={createBinding(speaker, "volume_icon")}
						minValue={0}
						maxValue={1}
						currentValue={createBinding(speaker, "volume")}
					/>
				)
			}}
		</For>
	)
}
