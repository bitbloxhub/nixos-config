<script lang="ts">
	import { onMount } from "svelte"
	import { createQuery } from "@tanstack/svelte-query"
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { Button, Select } from "bits-ui"
	import Icon from "@iconify/svelte"

	import CavaVisualizer from "./CavaVisualizer.svelte"
	import {
		actOnMprisPlayer,
		setMprisSource,
		streamMprisPlayers,
		streamMprisSource,
	} from "$lib/web-api/sdk.gen"
	import {
		activeMprisPlayer,
		automaticMprisSourceValue,
		defaultMprisSource,
	} from "$lib/mpris-source.svelte"
	import type { MprisPlayer, MprisSource } from "$lib/types"

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

	const sourceQuery = createQuery(() => ({
		queryKey: ["mpris-source-stream"],
		queryFn: experimental_streamedQuery<MprisSource, MprisSource>({
			initialValue: defaultMprisSource,
			refetchMode: "replace",
			reducer: (_, chunk) => chunk,
			streamFn: async ({ signal }) => (await streamMprisSource({ signal })).stream,
		}),
		enabled: false,
	}))
	let players = $derived(playersQuery.data ?? [])
	let mprisSource = $derived(sourceQuery.data ?? defaultMprisSource)
	let activePlayer = $derived(activeMprisPlayer(players, mprisSource))
	let sourceOptions = $derived([
		{ value: automaticMprisSourceValue, label: "Automatic", currentlyPlaying: false },
		...players.map((player) => ({
			value: player.serviceName,
			label: formatPlayerName(player),
			currentlyPlaying: player.playbackStatus === "Playing",
		})),
	])
	let selectedSource = $derived(
		mprisSource.serviceName &&
			players.some((player) => player.serviceName === mprisSource.serviceName)
			? mprisSource.serviceName
			: automaticMprisSourceValue,
	)
	let progress = $derived(
		activePlayer?.length ? Math.min(activePlayer.position / activePlayer.length, 1) : 0,
	)

	onMount(() => {
		void playersQuery.refetch()
		void sourceQuery.refetch()
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

	function formatPlayerName(player: MprisPlayer): string {
		const identity =
			player.identity || player.serviceName.replace(/^org\.mpris\.MediaPlayer2\./, "")
		const normalizedIdentity = identity.toLowerCase()

		if (normalizedIdentity === "spotify" || normalizedIdentity.startsWith("spotify."))
			return "Spotify"
		if (normalizedIdentity === "firefox" || normalizedIdentity.startsWith("firefox."))
			return "Firefox"

		return identity
	}
</script>

<section
	class="relative col-span-7 flex min-h-[28rem] flex-col justify-end overflow-hidden rounded-2xl bg-ctp-surface0 p-6"
	style={`background-image: linear-gradient(to top, rgb(17 17 27 / 0.96), rgb(17 17 27 / 0.2)), url(${activePlayer?.artUrl || ""}); background-size: cover; background-position: center;`}
>
	<div class="absolute right-4 top-4 z-20 flex flex-col items-end gap-1.5">
		<span class="mr-1 text-[10px] font-semibold uppercase tracking-[0.18em] text-ctp-subtext0"
			>MPRIS source</span
		>
		<Select.Root
			type="single"
			value={selectedSource}
			items={sourceOptions}
			onValueChange={(value) =>
				void setMprisSource({
					body: {
						serviceName: value === automaticMprisSourceValue ? null : value,
					},
				})}
		>
			<Select.Trigger
				class="flex w-40 items-center gap-2 rounded-xl border border-ctp-surface2 bg-ctp-base/90 px-2.5 py-1.5 text-left text-xs font-medium text-ctp-text shadow-xl shadow-ctp-crust/50 backdrop-blur-md transition hover:border-ctp-mauve/70 hover:bg-ctp-surface0 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ctp-mauve/70"
				aria-label="MPRIS source"
			>
				<Icon icon="mdi:music-note" width="16" class="shrink-0 text-ctp-mauve" />
				<Select.Value class="min-w-0 flex-1 truncate" placeholder="Automatic" />
				<Icon icon="mdi:chevron-down" width="16" class="ml-auto shrink-0 text-ctp-subtext0" />
			</Select.Trigger>
			<Select.Portal>
				<Select.Content
					class="z-50 w-44 overflow-hidden rounded-xl border border-ctp-surface2 bg-ctp-mantle/95 p-1 font-mono text-ctp-text shadow-2xl backdrop-blur-xl"
					sideOffset={6}
				>
					<Select.Viewport class="max-h-64 overflow-y-auto">
						{#each sourceOptions as option (option.value)}
							<Select.Item
								class="flex min-h-9 w-full items-center rounded-lg px-2.5 py-1.5 text-xs text-ctp-subtext1 outline-none transition-colors data-highlighted:bg-ctp-surface0 data-highlighted:text-ctp-text"
								value={option.value}
								label={option.label}
							>
								{#snippet children({ selected })}
									<Icon
										icon={option.value === automaticMprisSourceValue
											? "mdi:autorenew"
											: "mdi:music-note"}
										width="16"
										class="shrink-0 text-ctp-mauve"
									/>
									<span class="min-w-0 flex-1 truncate">{option.label}</span>
									{#if option.currentlyPlaying}
										<span
											class="ml-2 text-[10px] font-semibold uppercase tracking-wider text-ctp-green"
											>Playing</span
										>
									{/if}
									{#if selected}
										<Icon icon="mdi:check" width="16" class="ml-1 shrink-0 text-ctp-mauve" />
									{/if}
								{/snippet}
							</Select.Item>
						{/each}
					</Select.Viewport>
				</Select.Content>
			</Select.Portal>
		</Select.Root>
	</div>
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
