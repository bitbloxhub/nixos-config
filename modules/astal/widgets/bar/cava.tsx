import { createBinding } from "ags"
import AstalCava from "gi://AstalCava"

export default function Cava() {
	const cava = AstalCava.get_default()!
	cava.set_bars(12)

	const blocks = [
		"\u2581",
		"\u2582",
		"\u2583",
		"\u2584",
		"\u2585",
		"\u2586",
		"\u2587",
		"\u2588",
	]

	return (
		<menubutton>
			<label
				label={createBinding(cava, "values").as((values) =>
					values
						.map(
							(val) =>
								blocks[
									Math.min(
										Math.floor(val * 8),
										blocks.length - 1,
									)
								],
						)
						.join(""),
				)}
			/>
		</menubutton>
	)
}
