local key2spec = require("lzextras").key2spec

return {
	{
		"spider",
		keys = {
			key2spec({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", {}),
			key2spec({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", {}),
			key2spec({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", {}),
			key2spec({ "n", "o", "x" }, "ge", "<cmd>lua require('spider').motion('ge')<CR>", {}),
		},
		after = function()
			require("spider").setup({
				skipInsignificantPunctuation = false,
			})
		end,
	},
	{
		"nvim-treesitter-textobjects",
		event = "DeferredUIEnter",
		after = function()
			require("nvim-treesitter-textobjects").setup({})
		end,
	},
	{
		"various-textobjs",
		event = "DeferredUIEnter",
		after = function()
			require("various-textobjs").setup({
				keymaps = {
					useDefaults = true,
				},
			})
		end,
	},
}
