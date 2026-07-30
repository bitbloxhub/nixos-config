<script lang="ts">
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { createQuery } from "@tanstack/svelte-query"
	import { onMount } from "svelte"
	import { streamTimezone } from "$lib/web-api/sdk.gen"
	import type { StreamTimezoneResponse } from "$lib/web-api/types.gen"

	let { configured = false }: { configured?: boolean } = $props()
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
		formatTime(now, timezoneQuery.data?.[configured ? "timezone" : "systemTimezone"]),
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
	class="col-span-4 flex min-h-20 flex-col justify-between rounded-2xl bg-ctp-surface0 p-4"
	aria-label={configured ? "Local time" : "System time"}
>
	<span class="text-sm text-ctp-subtext1">{configured ? "Local time" : "System time"}</span>
	<span class="whitespace-nowrap text-xl font-semibold leading-normal">{currentTime}</span>
</section>
