return {
	{
		"nvim-bqf",
		after = function()
			require("bqf").setup({
				preview = { winblend = 0 },
			})
		end,
	},
	{
		"quicker.nvim",
		event = "DeferredUIEnter",
		after = function()
			require("quicker").setup({})
		end,
	},
	{
		"qfctl",
		event = "DeferredUIEnter",
		after = function()
			require("qfctl").setup({})
		end,
	},
}
