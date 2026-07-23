<script lang="ts">
	import { onMount } from "svelte"
	import { createQuery } from "@tanstack/svelte-query"
	import { getConfiguredTimezoneOptions } from "$lib/web-api/@tanstack/svelte-query.gen"

	let { configured = false }: { configured?: boolean } = $props()
	let now = $state(new Date())
	const configuredTimezone = createQuery(() => ({
		...getConfiguredTimezoneOptions(),
		enabled: false,
	}))
	let currentTime = $derived(formatTime(now, configuredTimezone.data?.timezone))

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
	class="col-span-4 flex min-h-20 flex-col justify-between rounded-2xl bg-ctp-surface0 p-4"
	aria-label={configured ? "Local time" : "System time"}
>
	<span class="text-sm text-ctp-subtext1">{configured ? "Local time" : "System time"}</span>
	<span class="whitespace-nowrap text-xl font-semibold leading-normal">{currentTime}</span>
</section>
