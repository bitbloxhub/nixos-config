local key2spec = require("lzextras").key2spec

return {
	"fidget.nvim",
	lazy = false,
	keys = {
		key2spec("n", "<leader>fh", function()
			-- From https://github.com/j-hui/fidget.nvim/issues/291#issuecomment-3662071064
			local fidget = require("fidget")

			local history_items = fidget.notification.get_history()

			if not history_items or #history_items == 0 then
				vim.notify("No fidget history available", vim.log.levels.WARN)
				return
			end

			local buf = vim.api.nvim_create_buf(false, true)

			vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
			vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
			vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

			local lines = {
				"== Fidget Notification History ==",
				"",
			}

			local highlights = {}

			for _, item in ipairs(history_items) do
				local lnum = #lines
				local timestamp = vim.fn.strftime("%c", item.last_updated)
				local group = item.group_name or "Notifications"
				local icon = item.annotate or "ℹ"

				local header = "(" .. timestamp .. ") " .. group .. " | [" .. icon .. "]"

				table.insert(lines, header)

				-- timestamp (grey)
				table.insert(highlights, {
					line = lnum,
					start = 0,
					finish = #timestamp + 2,
					group = "Comment",
				})

				-- group name (pink)
				local group_start = header:find(group, 1, true) - 1
				table.insert(highlights, {
					line = lnum,
					start = group_start,
					finish = group_start + #group,
					group = "String",
				})

				-- icon highlight
				local icon_start = header:find("%[", 1) - 1
				local icon_hl = "DiagnosticInfo"

				if icon:find("") then
					icon_hl = "DiagnosticWarn"
				elseif icon:find("") then
					icon_hl = "DiagnosticError"
				end

				table.insert(highlights, {
					line = lnum,
					start = icon_start,
					finish = #header,
					group = icon_hl,
				})

				-- message body
				for msg_line in vim.gsplit(item.message, "\n", { plain = true }) do
					table.insert(lines, "  " .. msg_line)
				end

				table.insert(lines, "")
			end

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

			-- Apply highlights
			for _, hl in ipairs(highlights) do
				-- TODO: switch to non-deprecated APIs
				---@diagnostic disable-next-line: deprecated
				vim.api.nvim_buf_add_highlight(buf, -1, hl.group, hl.line, hl.start, hl.finish)
			end

			-- From https://vi.stackexchange.com/questions/36594/how-do-i-open-an-existing-file-in-a-floating-window
			local width = vim.api.nvim_get_option_value("columns", { scope = "global" })
			local height = vim.api.nvim_get_option_value("lines", { scope = "global" })

			local win_height = math.ceil(height * 0.8 - 4)
			local win_width = math.ceil(width * 0.8)

			local row = math.ceil((height - win_height) / 2 - 1)
			local col = math.ceil((width - win_width) / 2)

			local opts = {
				style = "minimal",
				relative = "editor",
				width = win_width,
				height = win_height,
				row = row,
				col = col,
				border = "rounded",
			}

			local win = vim.api.nvim_open_win(buf, true, opts)
			vim.api.nvim_set_option_value("cursorline", true, {
				win = win,
			})

			vim.api.nvim_win_set_buf(win, buf)
			vim.api.nvim_buf_set_name(buf, "fidget://history.md")
		end, { desc = "[F]idget [H]istory" }),
	},
	after = function()
		require("fidget").setup({
			notification = {
				override_vim_notify = true,
				window = {
					winblend = 0,
				},
			},
		})
	end,
}
