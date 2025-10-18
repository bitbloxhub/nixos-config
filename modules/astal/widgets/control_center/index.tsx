import { Accessor, createBinding, createState, Setter } from "ags"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import NiriGObject from "../../utils/niri"
import Audio from "./audio"

export default function ControlCenter({
	niri,
	showingControlCenter,
	setShowingControlCenter,
}: {
	niri: NiriGObject
	showingControlCenter: Accessor<boolean>
	setShowingControlCenter: Setter<boolean>
}) {
	const { TOP, RIGHT } = Astal.WindowAnchor

	const [revealControlCenter, setRevealControlCenter] = createState(false)

	showingControlCenter.subscribe(() => {
		if (!showingControlCenter.get()) {
			setRevealControlCenter(false)
			setTimeout(() => {
				window.visible = showingControlCenter.get()
			}, 300)
		} else {
			window.visible = showingControlCenter.get()
		}
	})

	const window = (
		<window
			onNotifyVisible={(self) => {
				setRevealControlCenter(self.visible)
			}}
			defaultHeight={-1}
			defaultWidth={-1}
			name="control_center"
			gdkmonitor={createBinding(niri, "currentMonitor")}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			keymode={Astal.Keymode.EXCLUSIVE}
			anchor={TOP | RIGHT}
			application={app}
		>
			<Gtk.EventControllerKey
				onKeyPressed={(_e, keyval) => {
					if (keyval == Gdk.KEY_Escape) {
						setShowingControlCenter(false)
					}
				}}
			/>
			<revealer
				revealChild={revealControlCenter}
				transitionDuration={300}
				transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
			>
				<box orientation={Gtk.Orientation.VERTICAL}>
					<Audio />
				</box>
			</revealer>
		</window>
	) as Astal.Window

	return window
}
