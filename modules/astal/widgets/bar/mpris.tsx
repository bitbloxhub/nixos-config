import { Gtk } from "ags/gtk4"
import { Accessor, For, createState, createBinding, createComputed } from "ags"
import AstalMpris from "gi://AstalMpris"
import AstalApps from "gi://AstalApps"
import RoundImage from "../../components/RoundImage"
import Pango from "gi://Pango?version=1.0"
import Adw from "gi://Adw?version=1"

function Player({ player }: { player: AstalMpris.Player }) {
	const artist = createBinding(player, "artist")
	const title = createBinding(player, "title")
	const artistTitle = createComputed(() => {
		return `${artist()} - ${title()}`
	})

	return (
		<box
			class="mpris-player"
			name={player.bus_name}
			$type="named"
			orientation={Gtk.Orientation.VERTICAL}
			halign={Gtk.Align.CENTER}
			valign={Gtk.Align.CENTER}
		>
			<Gtk.AspectFrame ratio={1} class="mpris-cover">
				<RoundImage
					size={256}
					radius={10}
					file={createBinding(player, "coverArt")}
				/>
			</Gtk.AspectFrame>
			<label
				label={artistTitle}
				wrap
				wrapMode={Pango.WrapMode.WORD_CHAR}
			/>
			<slider
				widthRequest={256}
				value={createBinding(player, "position")}
				onChangeValue={({ value }) => player.set_position(value)}
				step={1}
				max={createBinding(player, "length")}
			/>
			<box halign={Gtk.Align.CENTER}>
				<button
					iconName="tabler-player-track-prev-symbolic"
					onClicked={() => {
						player.previous()
					}}
					class="control-button"
				/>
				<button
					iconName={createBinding(
						player,
						"playback_status",
					)(() => {
						if (
							player.playback_status ==
							AstalMpris.PlaybackStatus.PLAYING
						) {
							return "tabler-player-pause-symbolic"
						} else {
							return "tabler-player-play-symbolic"
						}
					})}
					onClicked={() => {
						player.play_pause()
					}}
					class="control-button"
				/>
				<button
					iconName="tabler-player-track-next-symbolic"
					onClicked={() => {
						player.next()
					}}
					class="control-button"
				/>
			</box>
		</box>
	)
}

export default function Mpris() {
	const mpris = AstalMpris.get_default()
	const apps = new AstalApps.Apps()
	const playersBinding = createBinding(mpris, "players")
	const players = playersBinding((players) => {
		return players.filter((player) => {
			return player.entry != null
		})
	})
	const [activePlayer, setActivePlayer] = createState<AstalMpris.Player>(
		players.peek()[0],
	)
	// TODO: figure out why bindings are not working with this
	const shouldShow = players((players) => {
		return players.length != 0
	})
	const activePlayerBusName = activePlayer((player) => {
		return player?.bus_name || ""
	})
	const activePlayerIdentity = activePlayer((player) => {
		return player?.identity || "No Players!"
	})
	const nextPlayer = (shiftNum: number) => {
		const players_list = players.peek()

		const newPlayer =
			players_list[
				(players_list.findIndex((player) => {
					return player.bus_name == activePlayerBusName.peek()
				}) +
					shiftNum) %
					players_list.length
			]

		setActivePlayer(newPlayer)
	}

	return (
		<menubutton class="mpris-button" visible={shouldShow}>
			<box>
				<For each={players}>
					{(player) => {
						const [app] = apps.exact_query(player.entry)
						const artist = createBinding(player, "artist")
						const title = createBinding(player, "title")
						const artistTitle = createComputed(() => {
							return `${artist()} - ${title()}`
						})
						return (
							<box>
								<label
									label={artistTitle}
									maxWidthChars={50}
									ellipsize={Pango.EllipsizeMode.END}
									class="mpris-button-title"
								/>
								<image
									class="mpris-button-image"
									visible={!!app.iconName}
									iconName={app?.iconName}
								/>
							</box>
						)
					}}
				</For>
			</box>
			<popover class="mpris-popover" hasArrow={false}>
				<Adw.Clamp
					maximumSize={264}
					orientation={Gtk.Orientation.HORIZONTAL}
				>
					<box orientation={Gtk.Orientation.VERTICAL}>
						<box orientation={Gtk.Orientation.HORIZONTAL}>
							<button
								iconName="pan-start-symbolic"
								halign={Gtk.Align.START}
								onClicked={() => {
									nextPlayer(-1)
								}}
							/>
							<label
								label={activePlayerIdentity}
								hexpand
								halign={Gtk.Align.CENTER}
							/>
							<button
								iconName="pan-end-symbolic"
								halign={Gtk.Align.END}
								onClicked={() => {
									nextPlayer(1)
								}}
							/>
						</box>
						<box spacing={4} orientation={Gtk.Orientation.VERTICAL}>
							<stack
								visibleChildName={activePlayerBusName}
								transitionType={
									Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
								}
							>
								<For each={players}>
									{(player) => <Player player={player} />}
								</For>
							</stack>
						</box>
					</box>
				</Adw.Clamp>
			</popover>
		</menubutton>
	)
}
