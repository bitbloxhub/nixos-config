local key2spec = require("lzextras").key2spec

return {
	"yazi.nvim",
	event = "DeferredUIEnter",
	keys = {
		key2spec({ "n", "v" }, "<leader>-", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" }),
		key2spec(
			"n",
			"<leader>cw",
			"<cmd>Yazi cwd<cr>",
			{ desc = "Open the file manager in nvim's working directory" }
		),
		key2spec("n", "<C-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume the last yazi session" }),
	},
	after = function()
		require("yazi").setup({
			open_multiple_tabs = true,
			integrations = {
				grep_in_selected_files = "fzf-lua",
				grep_in_directory = "fzf-lua",
				bufdelete_implementation = function(bufnr)
					require("mini.bufremove").delete(bufnr)
				end,
			},
		})
	end,
}
