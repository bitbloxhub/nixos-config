<script lang="ts">
	import { onMount } from "svelte"
	import { Button } from "bits-ui"
	import Icon from "@iconify/svelte"

	import { controlBento } from "$lib/web-api/sdk.gen"
	import BentoClock from "./BentoClock.svelte"
	import BentoMpris from "./BentoMpris.svelte"
	import BentoNotifications from "./BentoNotifications.svelte"
	import BentoPower from "./BentoPower.svelte"

	onMount(() => {
		const closeOnEscape = (event: KeyboardEvent) => {
			if (event.key === "Escape") void closeBento()
		}

		window.addEventListener("keydown", closeOnEscape)
		return () => window.removeEventListener("keydown", closeOnEscape)
	})

	async function closeBento(): Promise<void> {
		await controlBento({ body: { action: "close" } })
	}
</script>

<div class="relative grid h-full w-full place-items-center bg-transparent p-4 font-mono">
	<section
		class="relative grid h-fit max-h-full w-full max-w-5xl grid-cols-12 gap-3 rounded-3xl border border-ctp-surface2 bg-ctp-base/95 p-3 pt-14 text-ctp-text shadow-2xl"
	>
		<h1 class="absolute left-4 top-4 text-lg font-semibold">Bento</h1>
		<Button.Root
			class="absolute right-3 top-3 z-20 grid size-8 place-items-center rounded-xl bg-ctp-surface1 text-ctp-subtext1 hover:bg-ctp-surface2 hover:text-ctp-text"
			aria-label="Close bento"
			onclick={() => void closeBento()}
		>
			<Icon icon="mdi:close" width="18" />
		</Button.Root>

		<BentoMpris />
		<BentoNotifications />
		<BentoClock />
		<BentoClock configured />
		<BentoPower />
	</section>
</div>
