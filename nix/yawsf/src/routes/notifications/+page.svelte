<script lang="ts">
	import NotificationStack from "$lib/components/notifications/NotificationStack.svelte"
</script>

<svelte:head>
	<title>Notifications</title>
</svelte:head>

<main class="w-full overflow-visible bg-transparent font-mono">
	<NotificationStack />
</main>

<style>
	:global(html),
	:global(body) {
		scrollbar-width: none;
	}

	:global(html::-webkit-scrollbar),
	:global(body::-webkit-scrollbar) {
		display: none;
	}
</style>
