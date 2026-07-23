<script lang="ts">
	import { createMutation, createQuery } from "@tanstack/svelte-query"
	import { experimental_streamedQuery } from "@tanstack/query-core"
	import { onMount } from "svelte"
	import { Button } from "bits-ui"
	import { scale } from "svelte/transition"
	import {
		focusNiriWorkspaceMutation,
		listNiriWorkspacesOptions,
	} from "$lib/web-api/@tanstack/svelte-query.gen"
	import { streamNiriEvents } from "$lib/web-api/sdk.gen"
	import type { NiriWorkspace } from "$lib/types"

	const focusWorkspaceMutation = createMutation(() => focusNiriWorkspaceMutation())
	const workspacesQuery = createQuery(() => ({
		queryKey: ["niri-workspaces-stream"],
		queryFn: experimental_streamedQuery<Record<string, unknown>, NiriWorkspace[]>({
			initialValue: [],
			refetchMode: "replace",
			reducer: applyEvent,
			streamFn: async function* ({ signal, client }) {
				const snapshot = await client.fetchQuery(listNiriWorkspacesOptions())
				yield { WorkspacesChanged: { workspaces: snapshot ?? [] } }

				const stream = (await streamNiriEvents({ signal })).stream
				for await (const event of stream) yield event
			},
		}),
		enabled: false,
	}))
	let workspaces = $derived(workspacesQuery.data ?? [])

	async function focusWorkspace(index: number) {
		await focusWorkspaceMutation.mutateAsync({ body: { index } })
	}

	onMount(() => {
		void workspacesQuery.refetch()
	})

	function applyEvent(
		workspaces: NiriWorkspace[],
		event: Record<string, unknown>,
	): NiriWorkspace[] {
		const workspacesChanged = event.WorkspacesChanged as
			{ workspaces?: NiriWorkspace[] } | undefined
		if (workspacesChanged?.workspaces) return workspacesChanged.workspaces

		const activated = event.WorkspaceActivated as { focused?: boolean; id?: number } | undefined
		if (!activated?.focused || activated.id === undefined) return workspaces

		return workspaces.map((workspace) => ({
			...workspace,
			is_focused: workspace.id === activated.id,
		}))
	}
</script>

<section
	class="mr-1 flex h-6 min-h-6 items-center gap-1 rounded-full bg-ctp-surface0 leading-6"
	aria-label="Workspace controls"
>
	<nav class="flex" aria-label="Workspaces">
		{#each workspaces as workspace (workspace.id)}
			<Button.Root
				class={`relative inline-flex h-6 min-h-6 items-center justify-center overflow-hidden rounded-full px-2 text-sm leading-none transition-all duration-300 ease-out ${workspace.is_focused ? "text-ctp-base" : "text-ctp-text hover:scale-105 hover:bg-ctp-surface1 hover:text-ctp-mauve"}`}
				aria-label={`Workspace ${workspace.name ?? workspace.idx}`}
				aria-pressed={workspace.is_focused}
				onclick={() => void focusWorkspace(workspace.idx)}
			>
				{#if workspace.is_focused}
					<span
						class="absolute inset-0 rounded-full bg-ctp-mauve"
						in:scale={{ start: 0.7, duration: 240 }}
						out:scale={{ duration: 160 }}
					></span>
				{/if}
				<span class="relative z-10 leading-normal">{workspace.name ?? workspace.idx}</span>
			</Button.Root>
		{/each}
	</nav>
</section>
