return {
	"catppuccin-nvim",
	lazy = false,
	after = function()
		require("catppuccin").setup({
			flavour = "mocha",
			float = {
				transparent = true,
			},
			transparent_background = true,
			integrations = {
				gitsigns = true,
				navic = {
					enabled = true,
					custom_bg = "NONE",
				},
			},
		})
		vim.cmd.colorscheme("catppuccin")
		-- tiny-inline-diagnostic.nvim fix
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "None" })
	end,
}
