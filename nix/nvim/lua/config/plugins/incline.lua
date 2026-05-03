return {
	"incline",
	event = "DeferredUIEnter",
	after = function()
		local catppuccin = require("catppuccin.palettes").get_palette()

		require("incline").setup({
			render = function(props)
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
				if filename == "" then
					filename = "[No Name]"
				end
				local ft_icon, ft_color = require("mini.icons").get("file", filename)

				local function get_git_diff()
					local icons = { removed = " ", changed = " ", added = " " }
					local signs = vim.b[props.buf].gitsigns_status_dict
					local labels = {}
					if signs == nil then
						return labels
					end
					for name, icon in pairs(icons) do
						if tonumber(signs[name]) and signs[name] > 0 then
							table.insert(labels, { icon .. signs[name] .. " ", group = "Diff" .. name })
						end
					end
					if #labels > 0 then
						table.insert(labels, { "┊" })
					end
					return labels
				end

				local function get_diagnostic_label()
					local icons = { error = " ", warn = " ", info = " ", hint = "H " }
					local label = {}

					for severity, icon in pairs(icons) do
						local n = #vim.diagnostic.get(
							props.buf,
							{ severity = vim.diagnostic.severity[string.upper(severity)] }
						)
						if n > 0 then
							table.insert(label, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
						end
					end
					if #label > 0 then
						table.insert(label, { "┊" })
					end
					return label
				end

				local function get_navic()
					local navic = require("nvim-navic")
					local label = {}

					if props.focused then
						for _, item in ipairs(navic.get_data(props.buf) or {}) do
							table.insert(label, {
								{ " > ", group = "NavicSeparator" },
								{ item.icon, group = "NavicIcons" .. item.type },
								{ item.name, group = "NavicText" },
							})
						end
						if #label > 0 then
							table.insert(label, { " ┊ " })
						end
					end

					return label
				end

				return {
					{ get_diagnostic_label() },
					{ get_git_diff() },
					{ get_navic() },
					{ (ft_icon or "") .. " ", group = ft_color, guibg = "NONE" },
					{
						filename .. " ",
						group = ft_color,
						gui = vim.bo[props.buf].modified and "bold,italic" or "bold",
					},
					{ "┊  " .. vim.api.nvim_win_get_number(props.win), guifg = catppuccin.blue },
				}
			end,
		})
	end,
}
