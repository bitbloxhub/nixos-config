<script lang="ts">
	import { createQuery } from "@tanstack/svelte-query"
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { onMount } from "svelte"
	import { streamCava } from "$lib/web-api/sdk.gen"

	let { active = false }: { active?: boolean } = $props()
	const cavaQuery = createQuery(() => ({
		queryKey: ["cava-stream"],
		queryFn: experimental_streamedQuery<number[], number[]>({
			initialValue: [],
			refetchMode: "replace",
			reducer: (_, chunk) => chunk,
			streamFn: async ({ signal }) => (await streamCava({ signal })).stream,
		}),
		enabled: false,
	}))
	let frame = $derived(cavaQuery.data ?? [])

	onMount(() => {
		void cavaQuery.refetch()
	})

	function barHeight(value: number): number {
		return Math.min(50, Math.max(0, value / 2))
	}
</script>

<svg
	class={`pointer-events-none absolute inset-x-0 top-1/2 z-0 h-full w-full -translate-y-1/2 ${active ? "opacity-50" : "opacity-20"}`}
	viewBox="0 0 100 100"
	preserveAspectRatio="none"
	aria-hidden="true"
>
	{#each frame as value, index}
		{@const count = Math.max(frame.length, 1)}
		{@const x = (index * 100) / count + 0.15}
		{@const width = 100 / count - 0.3}
		{@const height = barHeight(value)}
		<rect {x} y={50 - height} {width} {height} rx="0" class="fill-ctp-mauve" />
		<rect {x} y="50" {width} {height} rx="0" class="fill-ctp-mauve" />
	{/each}
</svg>
