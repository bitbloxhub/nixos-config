<script lang="ts">
	import { browser } from "$app/environment"
	import { QueryClient, QueryClientProvider } from "@tanstack/svelte-query"
	import favicon from "$lib/assets/favicon.svg"
	import "../app.css"

	let { children } = $props()
	const queryClient = new QueryClient({
		defaultOptions: {
			queries: { enabled: browser },
		},
	})
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<QueryClientProvider client={queryClient}>
	{@render children()}
</QueryClientProvider>
