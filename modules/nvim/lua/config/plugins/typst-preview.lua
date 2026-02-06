return {
	"typst-preview.nvim",
	event = "DeferredUIEnter",
	after = function()
		require("typst-preview").setup({
			invert_colors = vim.json.encode({ rest = "auto", image = "never" }),
		})
	end,
}
