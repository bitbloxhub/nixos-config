<script lang="ts">
	import { onMount } from "svelte"
	import { createQuery } from "@tanstack/svelte-query"
	import { getConfiguredTimezoneOptions } from "$lib/web-api/@tanstack/svelte-query.gen"

	let { configured = false, timezone }: { configured?: boolean; timezone?: string } = $props()
	let now = $state(new Date())
	const configuredTimezone = createQuery(() => ({
		...getConfiguredTimezoneOptions(),
		enabled: false,
	}))
	let currentTime = $derived(formatTime(now, timezone ?? configuredTimezone.data?.timezone))

	onMount(() => {
		const timer = window.setInterval(() => {
			now = new Date()
		}, 500)
		let timezoneTimer: number | undefined

		if (configured) {
			void configuredTimezone.refetch()
			timezoneTimer = window.setInterval(() => void configuredTimezone.refetch(), 1_000)
		}

		return () => {
			window.clearInterval(timer)
			if (timezoneTimer !== undefined) window.clearInterval(timezoneTimer)
		}
	})

	function formatTime(date: Date, timeZone?: string): string {
		const parts = new Intl.DateTimeFormat("en-US", {
			timeZone,
			year: "numeric",
			month: "2-digit",
			day: "2-digit",
			hour: "2-digit",
			minute: "2-digit",
			second: undefined,
			hour12: true,
			timeZoneName: "short",
		}).formatToParts(date)
		const value = (type: Intl.DateTimeFormatPartTypes) =>
			parts.find((part) => part.type === type)?.value ?? ""

		return `${value("year")}-${value("month")}-${value("day")} ${value("hour")}:${value("minute")} ${value("dayPeriod")} ${value("timeZoneName")}`
	}
</script>

<section
	class="flex h-6 min-h-6 items-center rounded-full bg-ctp-surface0 px-2 leading-6"
	aria-label="Clock"
>
	<span class="leading-normal">{currentTime}</span>
</section>
