<script lang="ts">
	import { onMount } from "svelte"
	import { createQuery } from "@tanstack/svelte-query"
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { cubicOut } from "svelte/easing"
	import { flip } from "svelte/animate"
	import { fade, fly } from "svelte/transition"

	import NotificationCard from "$lib/components/notifications/NotificationCard.svelte"
	import {
		dismissNotification,
		invokeNotificationAction,
		streamNotifications,
	} from "$lib/web-api/sdk.gen"
	import type { Notification } from "$lib/types"

	const notificationsQuery = createQuery(() => ({
		queryKey: ["bento-notifications-stream"],
		queryFn: experimental_streamedQuery<Notification[], Notification[]>({
			initialValue: [],
			refetchMode: "replace",
			reducer: (_, chunk) => chunk,
			streamFn: async ({ signal }) => (await streamNotifications({ signal })).stream,
		}),
		enabled: false,
	}))
	let notifications = $derived(notificationsQuery.data ?? [])

	onMount(() => {
		void notificationsQuery.refetch()
	})

	async function dismiss(id: number): Promise<void> {
		await dismissNotification({ path: { id } })
		notifications = notifications.filter((notification) => notification.id !== id)
	}

	async function invokeAction(id: number, actionId: string): Promise<void> {
		await invokeNotificationAction({ path: { id, actionId } })
	}
</script>

<section
	class="col-span-5 flex h-[28rem] max-h-full min-w-0 flex-col rounded-2xl bg-ctp-surface0 p-5"
>
	<div class="mb-3 flex items-center justify-between">
		<h2 class="text-lg font-semibold">Notifications</h2>
		<span class="text-xs text-ctp-subtext0">{notifications.length}</span>
	</div>
	<div
		class="min-h-0 flex-1 space-y-3 overflow-x-hidden overflow-y-auto overscroll-contain pr-3 [scrollbar-color:theme(colors.ctp.overlay0)_transparent] [scrollbar-gutter:stable] [scrollbar-width:thin] [&::-webkit-scrollbar]:w-1.5 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-ctp-overlay0 [&::-webkit-scrollbar-track]:bg-transparent"
	>
		{#each notifications as notification (notification.id)}
			<div
				class="relative w-full"
				animate:flip={{ duration: 240, easing: cubicOut }}
				in:fly={{ y: 10, duration: 260 }}
				out:fade={{ duration: 180 }}
			>
				<NotificationCard
					{notification}
					reducedMotion={true}
					paused={false}
					showTimeoutBar={false}
					onHover={() => undefined}
					onVisualTimeout={() => undefined}
					onDismiss={(id) => void dismiss(id)}
					onInvokeAction={(id, actionId) => void invokeAction(id, actionId)}
				/>
			</div>
		{:else}
			<p class="py-8 text-center text-sm text-ctp-subtext0">No notifications</p>
		{/each}
	</div>
</section>
