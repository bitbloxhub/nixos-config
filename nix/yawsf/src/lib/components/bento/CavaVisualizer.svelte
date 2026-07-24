<script lang="ts">
	import { createQuery } from "@tanstack/svelte-query"
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { onMount } from "svelte"
	import { streamCava } from "$lib/web-api/sdk.gen"

	let { active = false }: { active?: boolean } = $props()
	let canvas: HTMLCanvasElement
	let latestFrame: number[] = []
	let animationFrame = 0

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

	function requestDraw(frame: number[]): void {
		latestFrame = frame
		if (animationFrame || !canvas) return
		animationFrame = requestAnimationFrame(() => {
			animationFrame = 0
			draw()
		})
	}

	function draw(): void {
		const context = canvas?.getContext("2d")
		if (!context) return

		const bounds = canvas.getBoundingClientRect()
		const dpr = window.devicePixelRatio || 1
		const width = Math.max(1, Math.floor(bounds.width * dpr))
		const height = Math.max(1, Math.floor(bounds.height * dpr))
		if (canvas.width !== width || canvas.height !== height) {
			canvas.width = width
			canvas.height = height
		}

		context.clearRect(0, 0, width, height)
		context.fillStyle = "#cba6f7"
		const count = Math.max(latestFrame.length, 1)
		for (const [index, value] of latestFrame.entries()) {
			const x = (index * width) / count + 0.15 * dpr
			const barWidth = (100 / count - 0.3) * (width / 100)
			const barHeight = Math.min(height / 2, Math.max(0, (value / 2) * (height / 100)))
			context.fillRect(x, height / 2 - barHeight, barWidth, barHeight)
			context.fillRect(x, height / 2, barWidth, barHeight)
		}
	}

	$effect(() => requestDraw(cavaQuery.data ?? []))

	onMount(() => {
		const resizeObserver = new ResizeObserver(() => requestDraw(latestFrame))
		resizeObserver.observe(canvas)
		void cavaQuery.refetch()
		requestDraw(latestFrame)

		return () => {
			resizeObserver.disconnect()
			if (animationFrame) cancelAnimationFrame(animationFrame)
		}
	})
</script>

<canvas
	bind:this={canvas}
	class={`pointer-events-none absolute inset-x-0 top-1/2 z-0 h-full w-full -translate-y-1/2 ${active ? "opacity-50" : "opacity-20"}`}
	aria-hidden="true"
></canvas>
