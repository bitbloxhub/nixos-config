<script lang="ts">
	import { createQuery } from "@tanstack/svelte-query"
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { onMount } from "svelte"
	import { cubicOut } from "svelte/easing"
	import { flip } from "svelte/animate"
	import { fade } from "svelte/transition"
	import {
		dismissNotification,
		invokeNotificationAction,
		resizeNotifications,
		setNotificationPaused as updateNotificationPaused,
		streamNotifications,
	} from "$lib/web-api/sdk.gen"

	import type { Notification } from "$lib/types"
	import NotificationCard from "./NotificationCard.svelte"

	const notificationsQuery = createQuery(() => ({
		queryKey: ["notification-stack-stream"],
		queryFn: experimental_streamedQuery<Notification[], Notification[]>({
			initialValue: [],
			refetchMode: "replace",
			reducer: (_, chunk) => chunk,
			streamFn: async ({ signal }) => (await streamNotifications({ signal })).stream,
		}),
		enabled: false,
	}))
	let notifications = $derived(notificationsQuery.data ?? [])
	let reducedMotion = $state(false)
	let stackElement = $state<HTMLElement | null>(null)
	let hoveredNotificationId = $state<number | null>(null)
	let visuallyExpired = $state<Record<number, number>>({})
	let visibleNotifications = $derived(
		notifications.filter(
			(notification) => visuallyExpired[notification.id] !== notification.receivedAt,
		),
	)
	let reportedHeight = -1
	let resizeFrame: number | null = null
	let activeOutros = 0
	let heightReportPending = false
	function reportHeight(): void {
		if (activeOutros > 0) {
			heightReportPending = true
			return
		}
		if (!stackElement) return
		const height = visibleNotifications.length === 0 ? 0 : Math.ceil(stackElement.scrollHeight)
		if (height === reportedHeight) return

		reportedHeight = height
		void resizeNotifications({ body: { height } }).catch((error) => {
			console.error("notification resize failed", error)
		})
	}

	function scheduleReportHeight(): void {
		if (resizeFrame !== null) cancelAnimationFrame(resizeFrame)
		resizeFrame = requestAnimationFrame(() => {
			resizeFrame = null
			reportHeight()
		})
	}

	function startOutro(): void {
		activeOutros += 1
	}

	function endOutro(): void {
		activeOutros = Math.max(0, activeOutros - 1)
		if (activeOutros === 0 && heightReportPending) {
			heightReportPending = false
			scheduleReportHeight()
		}
	}

	onMount(() => {
		const media = window.matchMedia("(prefers-reduced-motion: reduce)")
		const updateMotionPreference = () => {
			reducedMotion = media.matches
		}

		updateMotionPreference()
		void notificationsQuery.refetch()
		media.addEventListener("change", updateMotionPreference)

		const resizeObserver = new ResizeObserver(scheduleReportHeight)

		if (stackElement) {
			resizeObserver.observe(stackElement)
			scheduleReportHeight()
		}

		return () => {
			if (resizeFrame !== null) cancelAnimationFrame(resizeFrame)
			resizeObserver.disconnect()
			media.removeEventListener("change", updateMotionPreference)
		}
	})

	async function dismiss(id: number): Promise<void> {
		await dismissNotification({ path: { id } })
	}

	async function invokeAction(id: number, actionId: string): Promise<void> {
		await invokeNotificationAction({ path: { id, actionId } })
	}

	async function setNotificationPaused(id: number, paused: boolean): Promise<void> {
		await updateNotificationPaused({ path: { id }, body: { paused } })
	}

	function setHoveredNotification(notification: Notification, hovered: boolean): void {
		if (hovered) {
			hoveredNotificationId = notification.id
		} else if (hoveredNotificationId === notification.id) {
			hoveredNotificationId = null
		}

		if (notification.expiresAt !== null) {
			void setNotificationPaused(notification.id, hovered)
		}
	}

	function expireVisually(notification: Notification): void {
		visuallyExpired = { ...visuallyExpired, [notification.id]: notification.receivedAt }
	}
</script>

<section
	bind:this={stackElement}
	class="box-border flex h-auto w-full select-none flex-col items-stretch gap-3 p-3"
	aria-label="Notifications"
	aria-live="polite"
>
	{#each visibleNotifications as notification, index (notification.id)}
		<div
			class="relative w-full"
			style={`z-index: ${visibleNotifications.length - index}`}
			animate:flip={{ duration: reducedMotion ? 0 : 360, easing: cubicOut }}
			out:fade={{ duration: reducedMotion ? 0 : 320 }}
			onoutrostart={startOutro}
			onoutroend={endOutro}
		>
			<NotificationCard
				{notification}
				{reducedMotion}
				paused={hoveredNotificationId === notification.id}
				onHover={(hovered: boolean) => setHoveredNotification(notification, hovered)}
				onVisualTimeout={() => expireVisually(notification)}
				onDismiss={dismiss}
				onInvokeAction={invokeAction}
			/>
		</div>
	{/each}
</section>
