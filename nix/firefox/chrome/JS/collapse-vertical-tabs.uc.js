// Work around the fix for Firefox Bug 1947526 (commit 8559325d3084ceee46bf3cf7d10029564b2752c8),
// which introduced an obvious regression: vertical tabs are forced open at startup
// for no good reason, ignoring sidebar.backupState.launcherExpanded = false.
(() => {
	let attempts = 0

	const collapse = () => {
		const state = window.SidebarController?._state

		if (!state && attempts++ < 100) {
			window.setTimeout(collapse, 100)
			return
		}

		if (state && Services.prefs.getBoolPref("sidebar.verticalTabs", false)) {
			state.launcherExpanded = false
		}
	}

	window.addEventListener("load", () => window.setTimeout(collapse, 0), { once: true })
})()
