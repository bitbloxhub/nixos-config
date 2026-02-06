local key2spec = require("lzextras").key2spec

return {
	"resession.nvim",
	lazy = false,
	keys = {
		key2spec("n", "<leader>ss", require("resession").save, {}),
		key2spec("n", "<leader>sl", require("resession").load, {}),
		key2spec("n", "<leader>sL", function()
			require("resession").load(nil, { dir = "dirsession" })
		end, {}),
		key2spec("n", "<leader>sd", require("resession").delete, {}),
	},
	after = function()
		require("resession").setup({})
		local autosave_timer = assert(vim.uv.new_timer())
		vim.api.nvim_create_autocmd("DirChanged", {
			callback = function()
				autosave_timer:start(
					0,
					60 * 1000,
					vim.schedule_wrap(function()
						require("resession").save(vim.fn.getcwd(), { dir = "dirsession", notify = false })
					end)
				)
			end,
		})
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				require("resession").save(vim.fn.getcwd(), { dir = "dirsession", notify = false })
			end,
		})
	end,
}
