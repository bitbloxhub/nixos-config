return {
	{
		"orgmode",
		event = "DeferredUIEnter",
		dep_of = { "org-roam" },
		after = function()
			require("orgmode").setup({
				org_agenda_files = "~/notes/**/*",
				org_default_notes_file = "~/notes/refile.org",
				org_startup_folded = "inherit",
				org_todo_keywords = { "TODO", "STARTED", "|", "DONE", "CANCELED" },
			})
		end,
	},
	{
		"org-roam",
		event = "DeferredUIEnter",
		after = function()
			require("org-roam").setup({
				directory = "~/notes/",
			})
		end,
	},
}
