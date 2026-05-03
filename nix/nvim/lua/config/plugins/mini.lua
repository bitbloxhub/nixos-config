local key2spec = require("lzextras").key2spec

return {
	"mini.nvim",
	event = "DeferredUIEnter",
	on_require = { "mini.icons", "mini.bufremove" },
	keys = {
		key2spec("n", "<leader>bd", function()
			require("mini.bufremove").delete(vim.fn.bufnr(), false)
		end, { desc = "Closes the current buffer" }),
	},
	after = function()
		require("mini.pairs").setup()
		require("mini.icons").setup()
		require("mini.statusline").setup()
		require("mini.jump2d").setup()
		require("mini.jump").setup()
		require("mini.comment").setup()
		require("mini.surround").setup()
		require("mini.bufremove").setup()
		require("mini.splitjoin").setup()
	end,
}
