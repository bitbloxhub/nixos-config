import type { MprisPlayer, MprisSource } from "$lib/types"

export const automaticMprisSourceValue = "__automatic__"

export const defaultMprisSource: MprisSource = {
	serviceName: null,
	lastPlayingServiceName: null,
}

export function activeMprisPlayer(
	players: MprisPlayer[],
	source: MprisSource,
): MprisPlayer | undefined {
	if (source.serviceName) {
		const selectedPlayer = players.find((player) => player.serviceName === source.serviceName)
		if (selectedPlayer) return selectedPlayer
	}

	const playing = players.filter((player) => player.playbackStatus === "Playing")
	const automaticPlayer =
		playing.find(isSpotify) ??
		playing.find((player) => player.serviceName === source.lastPlayingServiceName) ??
		playing[0]

	return (
		automaticPlayer ??
		players.find((player) => player.serviceName === source.lastPlayingServiceName) ??
		players[0]
	)
}

function isSpotify(player: MprisPlayer): boolean {
	return `${player.identity} ${player.serviceName}`.toLowerCase().includes("spotify")
}
