<script lang="ts">
	/* eslint-disable svelte/no-at-html-tags */
	import { Button } from "bits-ui"
	import Icon from "@iconify/svelte"
	import { animate } from "animejs"
	import { cubicIn } from "svelte/easing"
	import { fly } from "svelte/transition"

	import type { Notification } from "$lib/types"

	type TimeoutBarOptions = {
		notification: Notification
		paused: boolean
	}

	type Props = {
		notification: Notification
		reducedMotion: boolean
		paused: boolean
		onHover: (hovered: boolean) => void
		onVisualTimeout: () => void
		onDismiss: (id: number) => void
		onInvokeAction: (id: number, actionId: string) => void
		showTimeoutBar?: boolean
	}
	let {
		notification,
		reducedMotion,
		paused,
		onHover,
		onVisualTimeout,
		onDismiss,
		onInvokeAction,
		showTimeoutBar = true,
	}: Props = $props()
	let contentImage = $state(false)
	let hasNotificationTimeout = $derived(notification.visualExpiresAt !== null)

	function hasImageSource(icon: string): boolean {
		return (
			icon.startsWith("/") ||
			icon.startsWith("file:") ||
			icon.startsWith("data:image/") ||
			icon.startsWith("http://") ||
			icon.startsWith("https://")
		)
	}

	function classifyImage(event: Event): void {
		const image = event.currentTarget as HTMLImageElement
		const aspectRatio = image.naturalWidth / image.naturalHeight
		contentImage = aspectRatio > 1.5 || aspectRatio < 2 / 3
	}

	function isContentImage(): boolean {
		return contentImage || notification.appName.toLowerCase() === "niri"
	}

	function urgencyClass(urgency: number): string {
		if (urgency === 0) return "border-ctp-subtext0"
		if (urgency === 2) return "border-ctp-red"
		return "border-ctp-mauve"
	}

	function timeoutBar(node: HTMLElement, options: TimeoutBarOptions) {
		let { notification: currentNotification, paused: currentPaused } = options
		let animation = startTimeoutBar(node, currentNotification, onVisualTimeout)
		if (currentPaused) animation.pause()

		return {
			update(next: TimeoutBarOptions) {
				if (!sameNotification(currentNotification, next.notification)) {
					animation.pause()
					currentNotification = next.notification
					animation = startTimeoutBar(node, currentNotification, onVisualTimeout)
					if (next.paused) animation.pause()
				} else {
					currentNotification = next.notification
				}

				if (currentPaused !== next.paused) {
					if (next.paused) animation.pause()
					else animation.resume()
				}
				currentPaused = next.paused
			},
			destroy() {
				animation.pause()
			},
		}
	}

	function startTimeoutBar(
		node: HTMLElement,
		timeoutNotification: Notification,
		onComplete: () => void,
	) {
		const expiresAt = timeoutNotification.visualExpiresAt ?? Date.now()
		const duration = Math.max(0, expiresAt - timeoutNotification.receivedAt)
		const remaining = Math.max(0, expiresAt - Date.now())
		const progress = duration === 0 ? 0 : remaining / duration

		node.style.transform = `scaleX(${progress})`
		return animate(node, {
			scaleX: 0,
			duration: remaining,
			ease: "linear",
			onComplete,
		})
	}

	function sameNotification(left: Notification, right: Notification): boolean {
		return left.id === right.id && left.receivedAt === right.receivedAt
	}
</script>

<article
	class="relative w-full"
	onmouseenter={() => onHover(true)}
	onmouseleave={() => onHover(false)}
>
	<div
		class={`relative box-border flex w-full overflow-hidden gap-3 rounded-xl border-2 bg-ctp-base/95 p-3 text-ctp-text ${urgencyClass(notification.urgency)}`}
		in:fly={{
			x: reducedMotion ? 0 : 480,
			duration: reducedMotion ? 0 : 360,
		}}
		out:fly={{
			x: reducedMotion ? 0 : 480,
			duration: reducedMotion ? 0 : 320,
			easing: cubicIn,
		}}
	>
		{#if hasNotificationTimeout && showTimeoutBar}
			<div class="pointer-events-none absolute left-1/2 top-0 z-10 h-1 w-full -translate-x-1/2">
				<div
					use:timeoutBar={{ notification, paused }}
					class="h-full w-full origin-center bg-ctp-mauve/80"
				></div>
			</div>
		{/if}
		<div
			class="grid h-8 w-8 flex-none place-items-center overflow-hidden rounded-lg bg-ctp-surface0 text-ctp-mauve"
			aria-hidden="true"
		>
			{#if hasImageSource(notification.appIcon) && !isContentImage()}
				<img
					class="h-full w-full object-contain"
					src={notification.appIcon}
					alt=""
					onload={classifyImage}
				/>
			{:else}
				<Icon icon="mdi:bell-outline" width="22" height="22" />
			{/if}
		</div>

		<div class="min-w-0 flex-1">
			<div class="flex items-center justify-between gap-2">
				<span class="truncate text-xs font-medium text-ctp-subtext0">
					{notification.appName || "Notification"}
				</span>
				<Button.Root
					class="grid h-6 w-6 flex-none place-items-center rounded-md border-0 bg-transparent p-0 text-ctp-subtext0 hover:bg-ctp-surface1 hover:text-ctp-text focus-visible:outline-2 focus-visible:outline-ctp-mauve"
					aria-label="Dismiss notification"
					onclick={() => onDismiss(notification.id)}
				>
					<Icon icon="mdi:close" width="18" height="18" />
				</Button.Root>
			</div>
			<div class="mt-1 block text-sm leading-tight font-semibold">
				{@html notification.summary}
			</div>
			{#if notification.body}
				<p
					class="mb-0 mt-2 whitespace-pre-wrap break-words text-xs leading-normal text-ctp-subtext1"
				>
					{@html notification.body}
				</p>
			{/if}

			{#if hasImageSource(notification.appIcon) && isContentImage()}
				<img
					class="mt-2 max-h-48 w-full rounded-lg object-contain"
					src={notification.appIcon}
					alt=""
				/>
			{/if}

			{#if notification.actions.length > 0}
				<div class="mt-3 flex flex-wrap gap-2">
					{#each notification.actions as action (action.id)}
						<Button.Root
							class="rounded-md border-0 bg-ctp-surface1 px-2 py-1 text-xs text-ctp-text hover:bg-ctp-surface2 focus-visible:outline-2 focus-visible:outline-ctp-mauve"
							onclick={() => onInvokeAction(notification.id, action.id)}
						>
							{@html action.label}
						</Button.Root>
					{/each}
				</div>
			{/if}
		</div>
	</div>
</article>
