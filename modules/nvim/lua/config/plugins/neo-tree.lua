return {
	"neo-tree.nvim",
	lazy = false, -- neo-tree does its own lazy loading
	after = function()
		-- For lualine
		_G.__cached_neo_tree_selector = nil
		_G.__get_neo_tree_selector = function()
			return _G.__cached_neo_tree_selector
		end
		local events = require("neo-tree.events")

		require("neo-tree").setup({
			event_handlers = {
				{
					event = events.AFTER_RENDER,
					handler = function(state)
						if state.current_position == "left" or state.current_position == "right" then
							vim.api.nvim_win_call(state.winid, function()
								local str = require("neo-tree.ui.selector").get()
								if str then
									_G.__cached_neo_tree_selector = str
								end
							end)
						end
					end,
				},
			},
			sources = {
				"filesystem",
				"buffers",
				"git_status",
				"document_symbols",
			},
			source_selector = {
				sources = {
					{ source = "filesystem" },
					{ source = "buffers" },
					{ source = "git_status" },
					{ source = "document_symbols" },
				},
				separator = { left = " ", right = " " },
				highlight_separator = "NONE",
				highlight_separator_active = "NONE",
			},
			window = {
				width = 30,
			},
			default_component_configs = {
				icon = {
					provider = function(icon, node) -- setup a custom icon provider
						local text, hl
						local mini_icons = require("mini.icons")
						if node.type == "file" then -- if it's a file, set the text/hl
							text, hl = mini_icons.get("file", node.name)
						elseif node.type == "directory" then -- get directory icons
							text, hl = mini_icons.get("directory", node.name)
							-- only set the icon text if it is not expanded
							if node:is_expanded() then
								text = nil
							end
						end
						-- set the icon text/highlight only if it exists
						if text then
							icon.text = text
						end
						if hl then
							icon.highlight = hl
						end
					end,
				},
			},
		})
	end,
}
