<svelte:head>
	<title>YAWSF Bitbloxhub Shell</title>
</svelte:head>

<main>
	<p class="eyebrow">YAWSF bitbloxhub shell</p>
	<h1>Native desktop surfaces, rendered with SvelteKit</h1>
	<p>This app demonstrates a Niri-aware topbar and MPRIS controls backed by the YAWSF host API.</p>
	<p class="hint">Run this app through YAWSF to create native layer-shell surfaces.</p>
</main>

<style>
	:global(body) {
		margin: 0;
		background: #11111b;
		color: #e5e7eb;
		font-family: system-ui, sans-serif;
	}

	main {
		max-width: 44rem;
		margin: 0 auto;
		padding: 6rem 2rem;
	}

	.eyebrow {
		color: #7aa2f7;
		font-weight: 700;
		letter-spacing: 0.08em;
		text-transform: uppercase;
	}

	h1 {
		font-size: clamp(2rem, 6vw, 4rem);
		line-height: 1.05;
	}

	p {
		line-height: 1.6;
	}

	.hint {
		color: #9ca3af;
	}
</style>
