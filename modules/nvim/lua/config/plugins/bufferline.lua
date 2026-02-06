local key2spec = require("lzextras").key2spec

return {
	{
		"cokeline",
		event = "DeferredUIEnter",
		dep_of = { "lualine" },
		keys = {
			-- TODO: get these to work
			key2spec("n", "<leader>bD", function()
				require("cokeline.mappings").pick("close-multiple")
			end, { desc = "pick buffer to delete" }),
			key2spec("n", "<leader>bb", function()
				require("cokeline.mappings").pick("focus")
			end, { desc = "pick buffer to open" }),
			key2spec("n", "[b", "<Plug>(cokeline-focus-prev)", { desc = "previous buffer" }),
			key2spec("n", "]b", "<Plug>(cokeline-focus-next)", { desc = "next buffer" }),
			key2spec("n", "[t", "<cmd>tabp<CR>", { desc = "previous tab" }),
			key2spec("n", "]t", "<cmd>tabn<CR>", { desc = "next tab" }),
		},
		after = function()
			-- Horrible crimes to use lualine and cokeline together for the bufferline
			-- From cokeline setup https://github.com/willothy/nvim-cokeline/blob/9fbed130683b7b6f73198c09e35ba4b33f547c08/lua/cokeline/init.lua#L10-L23
			local cokeline_config = require("cokeline.config")

			local catppuccin = require("catppuccin.palettes").get_palette()
			local is_picking_focus = require("cokeline.mappings").is_picking_focus
			local is_picking_close = require("cokeline.mappings").is_picking_close

			cokeline_config.setup({
				sidebar = {
					filetype = { "neo-tree" },
					components = {
						{
							text = function(buf)
								return buf.filetype
							end,
							bold = true,
						},
					},
				},
				default_hl = {
					fg = function(buffer)
						return buffer.is_focused and catppuccin.text or catppuccin.overlay2
					end,
					bg = catppuccin.none,
				},

				tabs = {
					placement = "left",
					components = {
						{
							text = " ",
						},
						{
							text = function(tab)
								return tab.number
							end,
							fg = function(tab)
								if tab.is_active then
									return catppuccin.text
								else
									return catppuccin.overlay2
								end
							end,
						},
						{
							text = " ",
						},
					},
				},

				components = {
					{
						text = " ",
					},
					{
						text = function(buffer)
							return (is_picking_focus() or is_picking_close()) and buffer.pick_letter .. " "
								or require("mini.icons").get("file", buffer.filename) .. " "
						end,
						fg = function(buffer)
							return (is_picking_focus() and catppuccin.yellow)
								or (is_picking_close() and catppuccin.red)
								or select(2, require("mini.icons").get("file", buffer.filename))
						end,
					},
					{
						text = function(buffer)
							return buffer.unique_prefix
						end,
						fg = catppuccin.overlay1,
					},
					{
						text = function(buffer)
							return buffer.filename .. " "
						end,
						fg = function(buffer)
							-- Adapted from https://github.com/catppuccin/nvim/blob/beaf41a/lua/catppuccin/groups/integrations/barbar.lua
							if buffer.is_focused then
								if buffer.is_modified then
									return catppuccin.yellow
								else
									return catppuccin.text
								end
							else
								-- TODO: is_visible
								if buffer.is_modified then
									return catppuccin.yellow
								else
									return catppuccin.overlay0
								end
							end
						end,
					},
					{
						text = " ",
						on_click = function(_, _, _, _, buffer)
							require("mini.bufremove").delete(buffer.number)
						end,
					},
					{
						text = " ",
					},
				},
			})
			if cokeline_config.history and cokeline_config.history.enabled then
				require("cokeline.history").setup(cokeline_config.history.size)
			end

			require("cokeline.mappings").setup()
			require("cokeline.hover").setup()
			require("cokeline.augroups").setup()
		end,
	},
	{
		"lualine",
		event = "DeferredUIEnter",
		after = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
					section_separators = "",
					component_separators = "",
					always_show_tabline = true,
				},
				tabline = {
					lualine_a = {
						{
							function()
								local neo_tree_selector = _G.__get_neo_tree_selector()
								-- TODO: add padding to neo-tree window width
								return neo_tree_selector
							end,
							cond = function()
								local manager = require("neo-tree.sources.manager")
								local renderer = require("neo-tree.ui.renderer")

								local state_fs = manager.get_state("filesystem")
								local state_buf = manager.get_state("buffers")
								local state_git = manager.get_state("git_status")
								local state_document_symbols = manager.get_state("document_symbols")

								local window_exists = renderer.window_exists(state_fs)
									or renderer.window_exists(state_buf)
									or renderer.window_exists(state_git)
									or renderer.window_exists(state_document_symbols)
								return window_exists
							end,
							padding = 0,
							separator = "",
						},
					},
					lualine_b = {
						{
							function()
								-- Awesome cokeline rendering function that skips the sidebars
								-- Based on https://github.com/willothy/nvim-cokeline/blob/9fbed130683b7b6f73198c09e35ba4b33f547c08/lua/cokeline/init.lua#L25-L33
								-- and https://github.com/willothy/nvim-cokeline/blob/9fbed130683b7b6f73198c09e35ba4b33f547c08/lua/cokeline/rendering.lua#L226-L253
								local cokeline_config = require("cokeline.config")
								local cokeline_rendering = require("cokeline.rendering")
								local cokeline_components = require("cokeline.components")

								local visible_buffers = require("cokeline.buffers").get_visible()

								local cx = cokeline_rendering.prepare(visible_buffers)
								local rendered = ""
								if cokeline_config.tabs and cokeline_config.tabs.placement == "left" then
									rendered = rendered
										.. cokeline_components.render(cx.tabs)
										.. "%#"
										.. cokeline_config.fill_hl
										.. "#"
								end
								rendered = "%#"
									.. cokeline_config.fill_hl
									.. "#"
									.. rendered
									.. cokeline_components.render(cx.buffers)
									.. "%#"
									.. cokeline_config.fill_hl
									.. "#"
								-- TODO: get right-aligned tabs to work (probably via another lualine component)
								-- .. string.rep(" ", cx.gap)
								-- .. cokeline_components.render(cx.rhs)
								-- if cokeline_config.tabs and cokeline_config.tabs.placement == "right" then
								-- 	rendered = rendered
								-- 		.. "%#"
								-- 		.. cokeline_config.fill_hl
								-- 		.. "#"
								-- 		.. cokeline_components.render(cx.tabs)
								-- end
								return rendered
							end,
						},
					},
					lualine_c = {},
				},
			})

			-- Use mini.statusline
			require("lualine").hide({ place = { "statusline" }, unhide = false })
		end,
	},
}
