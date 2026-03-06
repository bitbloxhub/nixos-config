local key2spec = require("lzextras").key2spec

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
	{
		"org-notebook",
		ft = "org",
		keys = {
			key2spec({ "n", "v" }, "<leader><CR>", "<cmd>OrgNotebook run_cell<cr>", {
				desc = "Run org-notebook cell",
				ft = "org",
			}),
		},
		after = function()
			require("org-notebook").setup({})
		end,
	},
}
