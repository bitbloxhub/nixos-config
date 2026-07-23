<script lang="ts">
	import { createQuery } from "@tanstack/svelte-query"
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { onMount } from "svelte"
	import { animate } from "animejs"
	import Icon from "@iconify/svelte"
	import { streamMprisPlayers } from "$lib/web-api/sdk.gen"
	import type { StreamMprisPlayersResponse } from "$lib/web-api/types.gen"

	let now = $state(Date.now())
	let playerUpdatedAt = $state(Date.now())
	const playersQuery = createQuery(() => ({
		queryKey: ["mpris-stream"],
		queryFn: experimental_streamedQuery<StreamMprisPlayersResponse, StreamMprisPlayersResponse>({
			initialValue: [] as StreamMprisPlayersResponse,
			refetchMode: "replace",
			reducer: (_, chunk) => chunk,
			streamFn: async ({ signal }) => (await streamMprisPlayers({ signal })).stream,
		}),
		enabled: false,
	}))
	let players = $derived(playersQuery.data ?? [])
	let activePlayer = $derived(players[0])
	let progress = $derived.by(() => {
		if (!activePlayer?.length) return 0
		const elapsed = activePlayer.playbackStatus === "Playing" ? (now - playerUpdatedAt) * 1000 : 0
		return Math.min((activePlayer.position + elapsed) / activePlayer.length, 1)
	})

	onMount(() => {
		void playersQuery.refetch()
		const timer = window.setInterval(() => {
			now = Date.now()
		}, 1000)

		return () => window.clearInterval(timer)
	})

	$effect(() => {
		if (playersQuery.data) playerUpdatedAt = Date.now()
	})

	function marquee(container: HTMLElement) {
		const measure = container.querySelector<HTMLElement>("[data-marquee-measure]")!
		const track = container.querySelector<HTMLElement>("[data-marquee-track]")!
		const copy = track.querySelector<HTMLElement>("[data-marquee-copy]")!

		const forwardSpeed = 70
		const backwardSpeed = 180
		const gap = 32

		let loop: ReturnType<typeof animate> | undefined
		let returning: ReturnType<typeof animate> | undefined
		let hovered = false
		let distance = 0

		function currentX() {
			const transform = getComputedStyle(track).transform
			return transform === "none" ? 0 : new DOMMatrixReadOnly(transform).m41
		}

		function stopAnimations() {
			loop?.cancel()
			returning?.cancel()

			loop = undefined
			returning = undefined
		}

		function rebuild() {
			stopAnimations()
			track.style.transform = ""

			const labelWidth = measure.getBoundingClientRect().width
			const viewportWidth = container.clientWidth

			distance = labelWidth + gap

			const overflowing = labelWidth > viewportWidth + 0.5
			copy.hidden = !overflowing
			container.toggleAttribute("data-overflowing", overflowing)

			if (!overflowing) {
				container.removeAttribute("data-scrolling")
				return
			}

			if (hovered) startLoop()
		}

		function startLoop() {
			if (!container.hasAttribute("data-overflowing")) return

			returning?.cancel()
			returning = undefined

			track.style.transform = ""
			container.dataset.scrolling = ""

			loop = animate(track, {
				x: -distance,
				duration: (distance / forwardSpeed) * 1000,
				ease: "linear",
				loop: true,
			})
		}

		function returnToStart() {
			loop?.pause()

			const x = currentX()
			loop?.cancel()
			loop = undefined

			if (Math.abs(x) < 0.5) {
				track.style.transform = ""
				container.removeAttribute("data-scrolling")
				return
			}

			// Preserve the loop's current rendered position after cancelling it.
			track.style.transform = `translateX(${x}px)`

			returning = animate(track, {
				x: 0,
				duration: (Math.abs(x) / backwardSpeed) * 1000,
				ease: "linear",
				onComplete() {
					track.style.transform = ""
					returning = undefined
					container.removeAttribute("data-scrolling")
				},
			})
		}

		function enter() {
			hovered = true
			startLoop()
		}

		function leave() {
			hovered = false
			returnToStart()
		}

		const observer = new ResizeObserver(rebuild)
		observer.observe(measure)
		observer.observe(container.parentElement ?? container)

		container.addEventListener("mouseenter", enter)
		container.addEventListener("mouseleave", leave)

		rebuild()

		return {
			destroy() {
				observer.disconnect()
				container.removeEventListener("mouseenter", enter)
				container.removeEventListener("mouseleave", leave)
				stopAnimations()
			},
		}
	}
</script>

{#if activePlayer}
	<section
		class="flex h-6 min-h-6 w-96 shrink-0 items-center gap-2 rounded-full bg-ctp-surface0 px-2 leading-6 text-ctp-text"
		aria-label="Now playing"
	>
		<div
			class="relative grid size-5 shrink-0 place-items-center rounded-full p-0.5"
			style={`background: conic-gradient(var(--color-ctp-mauve) ${progress}turn, var(--color-ctp-surface2) 0);`}
		>
			{#if activePlayer.artUrl}
				<img class="size-full rounded-full object-cover" src={activePlayer.artUrl} alt="" />
			{:else}
				<Icon icon="mdi:music" width="16" height="16" class="block" />
			{/if}
		</div>
		<span
			use:marquee
			class="relative min-w-0 w-0 flex-1 overflow-hidden whitespace-nowrap leading-normal
				data-[overflowing]:[mask-image:linear-gradient(to_right,black_0%,black_calc(100%-1rem),transparent)]
				data-[scrolling]:[mask-image:linear-gradient(to_right,transparent,black_1rem,black_calc(100%-1rem),transparent)]"
		>
			<span
				data-marquee-measure
				class="pointer-events-none invisible absolute w-max"
				aria-hidden="true"
			>
				{activePlayer.artist} — {activePlayer.title}
			</span>

			<span data-marquee-track class="flex w-max gap-8">
				<span>{activePlayer.artist} — {activePlayer.title}</span>
				<span data-marquee-copy aria-hidden="true"
					>{activePlayer.artist} — {activePlayer.title}</span
				>
			</span>
		</span>
	</section>
{/if}
