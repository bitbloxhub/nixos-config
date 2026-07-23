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

	async function runAction(entry: PowerAction): Promise<void> {
		if (entry.confirm && !window.confirm(entry.confirm)) return

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
				onclick={() => void runAction(entry)}
			>
				<Icon icon={entry.icon} width="26" />
			</Button.Root>
		{/each}
	</div>
</section>
