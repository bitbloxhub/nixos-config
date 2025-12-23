import { Accessor, createState, For, getScope } from "ags"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import { Fzf } from "fzf"
import Adw from "gi://Adw?version=1"
import AppsProvider from "./apps"

export interface LauncherItem {
	rendered: Gtk.Widget
	searchTerm: string
}

export interface LauncherItemProvider {
	getItems: (_: {
		window: Astal.Window
		entry: Gtk.Entry
		search: (_: string) => void
	}) => Array<LauncherItem>
}

export const providers: { [key: string]: LauncherItemProvider } = {
	default: new AppsProvider(),
}

export default function Launcher() {
	const { BOTTOM, TOP, LEFT, RIGHT } = Astal.WindowAnchor
	const [entry, setEntry] = createState<Gtk.Entry | null>(null)
	const [items, setItems] = createState(new Array<LauncherItem>())

	const scope = getScope()

	const search = (query: string) => {
		if (query == "") {
			setItems([])
			return
		}

		let provider: LauncherItemProvider | null = null
		let deprefixedQuery = query
		for (let prefix in providers) {
			if (query.startsWith(prefix) && prefix != "default") {
				deprefixedQuery = query.slice(prefix.length)
				provider = providers[prefix]
				break
			}
		}
		if (provider == null) {
			provider = providers.default
		}

		setItems(
			new Fzf(
				provider.getItems({
					window,
					entry: entry.peek() as Gtk.Entry,
					search,
				}),
				{
					selector: (item) => `${item.searchTerm}`,
				},
			)
				.find(deprefixedQuery)
				.map((e) => e.item),
		)
	}

	const window = (
		<window
			name="launcher"
			anchor={BOTTOM | TOP | LEFT | RIGHT}
			application={app}
			exclusivity={Astal.Exclusivity.IGNORE}
			keymode={Astal.Keymode.EXCLUSIVE}
		>
			<Gtk.EventControllerKey
				onKeyPressed={(_e, keyval, _, mask) => {
					if (keyval == Gdk.KEY_Escape) {
						window.visible = false
					}

					if (mask === Gdk.ModifierType.ALT_MASK) {
						for (const i of [1, 2, 3, 4, 5, 6, 7, 8, 9] as const) {
							if (keyval === Gdk[`KEY_${i}`]) {
								items.peek()[i - 1].rendered.activate()
							}
						}
					}
				}}
			/>
			<Adw.Clamp maximumSize={700} orientation={Gtk.Orientation.VERTICAL}>
				<box
					class="launcher"
					valign={Gtk.Align.CENTER}
					halign={Gtk.Align.CENTER}
					orientation={Gtk.Orientation.VERTICAL}
					spacing={6}
				>
					<entry
						$={(self) => {
							setEntry(self)
							self.connect("notify::text", () => {
								scope.run(() => search(self.text))
							})
						}}
						placeholderText="Start typing to search"
					/>
					<Gtk.Separator visible={items((l) => l.length > 0)} />
					<scrolledwindow
						visible={items((l) => l.length > 0)}
						propagateNaturalHeight
						propagateNaturalWidth
						maxContentWidth={1}
					>
						<box orientation={Gtk.Orientation.VERTICAL}>
							<For each={items}>
								{(item) => {
									return (
										<Adw.Clamp
											maximumSize={500}
											orientation={
												Gtk.Orientation.HORIZONTAL
											}
										>
											{item.rendered}
										</Adw.Clamp>
									)
								}}
							</For>
						</box>
					</scrolledwindow>
				</box>
			</Adw.Clamp>
		</window>
	) as Astal.Window

	return window
}
