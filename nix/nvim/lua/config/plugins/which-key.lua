local key2spec = require("lzextras").key2spec

return {
	"which-key.nvim",
	event = "DeferredUIEnter",
	on_require = { "which-key" },
	keys = {
		key2spec("n", "<leader>?", function()
			require("which-key").show({ global = false })
		end, { desc = "Buffer Local Keymaps (which-key)" }),
	},
	after = function()
		require("which-key").setup({})

		require("which-key").add({
			{ "<leader>f", group = "[F]zf-lua" },
			{
				"<leader>w",
				function()
					return require("which-key").show({
						keys = "<C-w>",
						loop = true,
					})
				end,
				group = "[W]indow",
			},
		})
	end,
}
