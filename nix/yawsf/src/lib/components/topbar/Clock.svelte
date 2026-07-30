<script lang="ts">
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { createQuery } from "@tanstack/svelte-query"
	import { onMount } from "svelte"
	import { streamTimezone } from "$lib/web-api/sdk.gen"
	import type { StreamTimezoneResponse } from "$lib/web-api/types.gen"

	let { configured = false, timezone }: { configured?: boolean; timezone?: string } = $props()
	let now = $state(new Date())
	const timezoneQuery = createQuery(() => ({
		queryKey: ["timezone-stream"],
		queryFn: experimental_streamedQuery<StreamTimezoneResponse, StreamTimezoneResponse>({
			initialValue: { timezone: "UTC", systemTimezone: "UTC" },
			refetchMode: "replace",
			reducer: (_, chunk) => chunk,
			streamFn: async ({ signal }) => (await streamTimezone({ signal })).stream,
		}),
		enabled: false,
	}))
	let currentTime = $derived(
		formatTime(
			now,
			timezone ?? (configured ? timezoneQuery.data?.timezone : timezoneQuery.data?.systemTimezone),
		),
	)

	onMount(() => {
		const timer = window.setInterval(() => {
			now = new Date()
		}, 500)
		void timezoneQuery.refetch()
		return () => window.clearInterval(timer)
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
