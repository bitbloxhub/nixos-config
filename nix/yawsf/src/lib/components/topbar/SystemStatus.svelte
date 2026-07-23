<script lang="ts">
	import { onMount } from "svelte"
	import { createQuery } from "@tanstack/svelte-query"
	import Icon from "@iconify/svelte"
	import { getSystemStatusOptions } from "$lib/web-api/@tanstack/svelte-query.gen"

	const systemStatus = createQuery(() => ({
		...getSystemStatusOptions(),
		enabled: false,
	}))
	let battery = $derived(systemStatus.data?.battery.capacity ?? null)
	let charging = $derived(systemStatus.data?.battery.charging ?? false)

	onMount(() => {
		void systemStatus.refetch()
		const timer = window.setInterval(() => void systemStatus.refetch(), 1_000)

		return () => window.clearInterval(timer)
	})

	function batteryIcon(capacity: number | null, charging: boolean): string {
		if (capacity === null) return charging ? "mdi:battery-charging" : "mdi:battery-unknown"

		const level = Math.min(100, Math.max(10, Math.ceil(capacity / 10) * 10))
		if (charging) return `mdi:battery-charging-${level}`
		return level === 100 ? "mdi:battery" : `mdi:battery-${level}`
	}
</script>

<section
	class="ml-1 flex h-6 min-h-6 items-center gap-2 rounded-full bg-ctp-surface0 px-2 leading-6"
	aria-label="Battery"
>
	<Icon icon={batteryIcon(battery, charging)} width="14" height="14" class="block" />
	<span class="leading-normal">{battery === null ? "AC" : `${battery}%`}</span>
</section>
