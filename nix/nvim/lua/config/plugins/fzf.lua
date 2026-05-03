local key2spec = require("lzextras").key2spec

return {
	"fzf-lua",
	event = "DeferredUIEnter",
	keys = {
		key2spec("n", "<leader>f\\", require("fzf-lua").buffers, { desc = "Fzf Buffers" }),
		key2spec("n", "<leader>fk", require("fzf-lua").builtin, { desc = "Fzf Builtin" }),
		key2spec("n", "<leader>fp", require("fzf-lua").files, { desc = "Fzf Files" }),
		key2spec("n", "<leader>fg", require("fzf-lua").live_grep, { desc = "Fzf Grep" }),
		key2spec("n", "<leader>fG", require("fzf-lua").lgrep_curbuf, { desc = "Fzf Grep current buffer" }),
		key2spec("n", "<F1>", require("fzf-lua").help_tags, { desc = "Fzf Help" }),
	},
	after = function()
		require("fzf-lua").setup({
			lsp = {
				code_actions = {
					previewer = "codeaction_native",
				},
			},
		})
		require("fzf-lua").register_ui_select(function(_, items)
			local min_h, max_h = 0.15, 0.70
			local h = (#items + 4) / vim.o.lines
			if h < min_h then
				h = min_h
			elseif h > max_h then
				h = max_h
			end
			return { winopts = { height = h, width = 0.60, row = 0.40 } }
		end)
	end,
}
