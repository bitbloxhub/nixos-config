<script lang="ts">
	import { Button } from "bits-ui"
	import Icon from "@iconify/svelte"

	import {
		lockSystem,
		logoutSystem,
		rebootSystem,
		shutdownSystem,
		suspendSystem,
	} from "$lib/web-api/sdk.gen"

	type SystemAction = "lock" | "suspend" | "reboot" | "logout" | "shutdown"
	type PowerAction = {
		action: SystemAction
		label: string
		icon: string
		confirm?: string
		color: string
	}

	const actions: PowerAction[] = [
		{
			action: "lock",
			label: "Lock",
			icon: "mdi:lock",
			color:
				"bg-ctp-surface1 text-ctp-mauve border-transparent hover:bg-ctp-mauve/20 hover:border-ctp-mauve/40",
		},
		{
			action: "suspend",
			label: "Suspend",
			icon: "mdi:power-sleep",
			color:
				"bg-ctp-surface1 text-ctp-blue border-transparent hover:bg-ctp-blue/20 hover:border-ctp-blue/40",
		},
		{
			action: "logout",
			label: "Log out",
			icon: "mdi:logout",
			confirm: "Log out of Niri?",
			color:
				"bg-ctp-surface1 text-ctp-yellow border-transparent hover:bg-ctp-yellow/20 hover:border-ctp-yellow/40",
		},
		{
			action: "reboot",
			label: "Reboot",
			icon: "material-symbols:restart-alt-rounded",
			confirm: "Reboot this computer?",
			color:
				"bg-ctp-surface1 text-ctp-peach border-transparent hover:bg-ctp-peach/20 hover:border-ctp-peach/40",
		},
		{
			action: "shutdown",
			label: "Shut down",
			icon: "mdi:power",
			confirm: "Shut down this computer?",
			color:
				"bg-ctp-surface1 text-ctp-red border-transparent hover:bg-ctp-red/20 hover:border-ctp-red/40",
		},
	]
	let pendingAction = $state<PowerAction | null>(null)

	function requestAction(entry: PowerAction): void {
		if (entry.confirm) {
			pendingAction = entry
			return
		}

		void executeAction(entry)
	}

	async function executeAction(entry: PowerAction): Promise<void> {
		pendingAction = null

		const requests: Record<SystemAction, () => Promise<unknown>> = {
			lock: () => lockSystem(),
			suspend: () => suspendSystem(),
			reboot: () => rebootSystem(),
			logout: () => logoutSystem(),
			shutdown: () => shutdownSystem(),
		}

		await requests[entry.action]()
	}
</script>

<section
	class="col-span-12 flex w-fit max-w-full items-center gap-4 rounded-2xl bg-ctp-surface0 px-4 py-3"
>
	<h2 class="sr-only">Session</h2>
	<div class="flex gap-3">
		{#each actions as entry (entry.action)}
			<Button.Root
				class={`grid size-14 place-items-center rounded-xl border ${entry.color} transition-colors`}
				aria-label={entry.label}
				title={entry.label}
				onclick={() => requestAction(entry)}
			>
				<Icon icon={entry.icon} width="26" />
			</Button.Root>
		{/each}
	</div>
</section>

{#if pendingAction}
	<div
		class="fixed inset-0 z-50 grid place-items-center bg-ctp-crust/70 p-4"
		role="presentation"
		onclick={() => (pendingAction = null)}
	>
		<div
			class="w-full max-w-sm rounded-2xl border border-ctp-surface2 bg-ctp-base p-5 text-ctp-text shadow-2xl"
			role="dialog"
			aria-modal="true"
			aria-labelledby="system-action-title"
			tabindex="-1"
			onclick={(event) => event.stopPropagation()}
			onkeydown={(event) => event.stopPropagation()}
		>
			<h2 id="system-action-title" class="text-lg font-semibold">{pendingAction.label}</h2>
			<p class="mt-2 text-sm text-ctp-subtext1">{pendingAction.confirm}</p>
			<div class="mt-5 flex justify-end gap-2">
				<Button.Root
					class="rounded-lg bg-ctp-surface1 px-3 py-2 text-sm text-ctp-text hover:bg-ctp-surface2"
					onclick={() => (pendingAction = null)}
				>
					Cancel
				</Button.Root>
				<Button.Root
					class={`rounded-lg px-3 py-2 text-sm text-ctp-crust ${pendingAction.color}`}
					onclick={() => void executeAction(pendingAction!)}
				>
					Confirm
				</Button.Root>
			</div>
		</div>
	</div>
{/if}
