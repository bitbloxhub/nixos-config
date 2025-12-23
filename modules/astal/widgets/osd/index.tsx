import { Accessor, createBinding, createState } from "ags"
import NiriGObject from "../../utils/niri"
import { Astal, Gtk } from "ags/gtk4"
import Adw from "gi://Adw?version=1"
import Backlights from "./backlights"
import Speakers from "./speakers"
import GLib from "gi://GLib?version=2.0"

export function OsdWrapper({
	type,
	id,
	offsets = [],
	iconName,
	minValue,
	maxValue,
	currentValue,
}: {
	type: string
	id: Accessor<string>
	offsets?: Array<{ name: string; value: number }>
	iconName: string | Accessor<string>
	minValue: number | Accessor<number>
	maxValue: number | Accessor<number>
	currentValue: number | Accessor<number>
}) {
	return (
		<Adw.Clamp
			$type="named"
			name={id((id) => `${type}-${id}`)}
			maximumSize={1}
			orientation={Gtk.Orientation.VERTICAL}
		>
			<box class="osd" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
				<image iconName={iconName} pixelSize={48} />
				<levelbar
					$={(self) => {
						for (const offset of offsets) {
							self.add_offset_value(offset.name, offset.value)
						}
					}}
					class={type}
					widthRequest={150}
					heightRequest={35}
					minValue={minValue}
					maxValue={maxValue}
					value={currentValue}
				/>
			</box>
		</Adw.Clamp>
	)
}

export default function Osd({ niri }: { niri: NiriGObject }) {
	const { BOTTOM } = Astal.WindowAnchor

	const [currentOsd, setCurrentOsd] = createState("")
	const [revealOsd, setRevealOsd] = createState(false)
	const [timeoutSource, setTimeoutSource] = createState<GLib.Source | null>(
		null,
	)

	revealOsd.subscribe(() => {
		if (!revealOsd.peek()) {
			setTimeout(() => {
				window.visible = revealOsd.peek()
			}, 300)
		} else {
			window.visible = revealOsd.peek()
		}
	})

	const window = (
		<window
			defaultHeight={-1}
			defaultWidth={-1}
			gdkmonitor={createBinding(niri, "currentMonitor")}
			keymode={Astal.Keymode.NONE}
			anchor={BOTTOM}
			exclusivity={Astal.Exclusivity.NORMAL}
			name="osd"
		>
			<revealer
				transitionType={Gtk.RevealerTransitionType.SLIDE_UP}
				transitionDuration={300}
				revealChild={revealOsd}
			>
				<stack visibleChildName={currentOsd}>
					<Backlights
						setCurrentOsd={setCurrentOsd}
						setRevealOsd={setRevealOsd}
						timeoutSource={timeoutSource}
						setTimeoutSource={setTimeoutSource}
					/>
					<Speakers
						setCurrentOsd={setCurrentOsd}
						setRevealOsd={setRevealOsd}
						timeoutSource={timeoutSource}
						setTimeoutSource={setTimeoutSource}
					/>
				</stack>
			</revealer>
		</window>
	) as Astal.Window

	return window
}
