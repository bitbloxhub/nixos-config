<script lang="ts">
	import Clock from "$lib/components/topbar/Clock.svelte"
	import Mpris from "$lib/components/topbar/Mpris.svelte"
	import SystemStatus from "$lib/components/topbar/SystemStatus.svelte"
	import WorkspaceControls from "$lib/components/topbar/WorkspaceControls.svelte"
</script>

<svelte:head>
	<title>YAWSF Topbar</title>
</svelte:head>

<header
	class="topbar flex select-none items-center justify-between bg-transparent px-2 py-0 font-mono text-ctp-text"
>
	<WorkspaceControls />

	<div class="flex items-center gap-2">
		<Clock />
		<Mpris />
		<Clock configured />
	</div>

	<SystemStatus />
</header>

<style>
	:global(html) {
		background-color: transparent;
	}

	:global(body) {
		background-color: transparent;
	}

	.topbar {
		height: 31px;
		font-family: "Fira Code", monospace;
		font-size: 13.5px;
		font-weight: 500;
		font-variant-ligatures: none;
		line-height: 1;
		text-rendering: auto;
	}
</style>
