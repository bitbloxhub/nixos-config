import { Accessor, createState, For, Setter } from "ags"
import { monitorFile, readFile } from "ags/file"
import { exec } from "ags/process"
import GLib from "gi://GLib?version=2.0"
import { OsdWrapper } from "."

export default function Backlights({
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
	const [backlights, setBacklights] = createState<
		Array<{
			name: string
			maximum: number
			brightness: Accessor<number>
		}>
	>([])

	const reloadBacklights = () => {
		const sys_backlights: Array<{ name: string }> = JSON.parse(
			exec(`nu -c "ls /sys/class/backlight/ | to json"`),
		)
		setBacklights(
			sys_backlights.map((backlight) => {
				const backlight_file = `${backlight.name}/brightness`
				const [brightness, setBrightness] = createState(
					+readFile(backlight_file),
				)
				monitorFile(backlight_file, async () => {
					setBrightness(+readFile(backlight_file))
					setCurrentOsd(`brightness-${backlight.name}`)
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
				return {
					name: backlight.name,
					maximum: +readFile(`${backlight.name}/max_brightness`),
					brightness,
				}
			}),
		)
	}

	reloadBacklights()

	return (
		<For each={backlights}>
			{(backlight) => {
				return (
					<OsdWrapper
						type="brightness"
						id={createState(backlight.name)[0]}
						offsets={[
							{
								name: "low",
								value: 0.4 * backlight.maximum + 1,
							},
							{
								name: "medium",
								value: 0.7 * backlight.maximum + 1,
							},
							{
								name: "high",
								value: backlight.maximum,
							},
						]}
						iconName="tabler-brightness-up-symbolic"
						minValue={0}
						maxValue={backlight.maximum}
						currentValue={backlight.brightness}
					/>
				)
			}}
		</For>
	)
}
