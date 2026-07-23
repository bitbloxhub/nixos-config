<script lang="ts">
	import { onMount } from "svelte"
	import { createQuery } from "@tanstack/svelte-query"
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { Button } from "bits-ui"
	import Icon from "@iconify/svelte"

	import CavaVisualizer from "./CavaVisualizer.svelte"
	import { actOnMprisPlayer, streamMprisPlayers } from "$lib/web-api/sdk.gen"
	import type { MprisPlayer } from "$lib/types"

	const playersQuery = createQuery(() => ({
		queryKey: ["bento-mpris-stream"],
		queryFn: experimental_streamedQuery<MprisPlayer[], MprisPlayer[]>({
			initialValue: [],
			refetchMode: "replace",
			reducer: (_, chunk) => chunk,
			streamFn: async ({ signal }) => (await streamMprisPlayers({ signal })).stream,
		}),
		enabled: false,
	}))
	let players = $derived(playersQuery.data ?? [])
	let activePlayer = $derived(players[0])
	let progress = $derived(
		activePlayer?.length ? Math.min(activePlayer.position / activePlayer.length, 1) : 0,
	)

	onMount(() => {
		void playersQuery.refetch()
	})

	async function control(
		action: "playPause" | "next" | "previous" | "seek",
		offset = 0,
	): Promise<void> {
		if (!activePlayer) return
		await actOnMprisPlayer({
			path: { serviceName: activePlayer.serviceName, action },
			body: { offset },
		})
	}

	async function seekTo(position: number): Promise<void> {
		if (!activePlayer) return
		await control("seek", (position - activePlayer.position) / 1_000_000)
	}

	function formatTime(microseconds = 0): string {
		const seconds = Math.max(0, Math.floor(microseconds / 1_000_000))
		return `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, "0")}`
	}
</script>

<section
	class="relative col-span-7 flex min-h-[28rem] flex-col justify-end overflow-hidden rounded-2xl bg-ctp-surface0 p-6"
	style={`background-image: linear-gradient(to top, rgb(17 17 27 / 0.96), rgb(17 17 27 / 0.2)), url(${activePlayer?.artUrl || ""}); background-size: cover; background-position: center;`}
>
	<CavaVisualizer active={activePlayer?.playbackStatus === "Playing"} />
	<div class="relative z-10">
		<h1 class="truncate text-2xl font-semibold">{activePlayer?.title || "Nothing playing"}</h1>
		<p class="truncate text-sm text-ctp-subtext1">{activePlayer?.artist || "—"}</p>
		<div class="mt-3 flex items-center gap-3">
			<span class="text-xs text-ctp-subtext1">{formatTime(activePlayer?.position)}</span>
			<input
				class="h-1 w-full cursor-pointer accent-ctp-mauve"
				type="range"
				min="0"
				max={activePlayer?.length ?? 0}
				value={activePlayer?.position ?? 0}
				aria-label="Seek through track"
				oninput={(event) => void seekTo(Number((event.currentTarget as HTMLInputElement).value))}
			/>
			<span class="text-xs text-ctp-subtext1">{formatTime(activePlayer?.length)}</span>
		</div>
		<div class="mt-4 flex items-center justify-center gap-2">
			<Button.Root
				class="grid size-9 place-items-center rounded-full hover:bg-ctp-surface1"
				aria-label="Seek backward ten seconds"
				onclick={() => void control("seek", -10)}
				><Icon icon="mdi:rewind-10" width="20" /></Button.Root
			>
			<Button.Root
				class="grid size-9 place-items-center rounded-full hover:bg-ctp-surface1"
				aria-label="Previous"
				onclick={() => void control("previous")}
				><Icon icon="mdi:skip-previous" width="20" /></Button.Root
			>
			<Button.Root
				class="grid size-12 place-items-center rounded-full bg-ctp-mauve text-ctp-base hover:bg-ctp-lavender"
				aria-label="Play or pause"
				onclick={() => void control("playPause")}
				><Icon
					icon={activePlayer?.playbackStatus === "Playing" ? "mdi:pause" : "mdi:play"}
					width="24"
				/></Button.Root
			>
			<Button.Root
				class="grid size-9 place-items-center rounded-full hover:bg-ctp-surface1"
				aria-label="Next"
				onclick={() => void control("next")}><Icon icon="mdi:skip-next" width="20" /></Button.Root
			>
			<Button.Root
				class="grid size-9 place-items-center rounded-full hover:bg-ctp-surface1"
				aria-label="Seek forward ten seconds"
				onclick={() => void control("seek", 10)}
				><Icon icon="mdi:fast-forward-10" width="20" /></Button.Root
			>
		</div>
	</div>
</section>
