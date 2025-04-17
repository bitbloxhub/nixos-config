local function set_user_var(key, value)
	io.write(string.format("\027]1337;SetUserVar=%s=%s\a", key, vim.base64.encode(tostring(value))))
end

if vim.env.PROF then
	require("snacks.profiler").startup({
		startup = {
			event = "VimEnter",
		},
	})
end

vim.o.termguicolors = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.clipboard = "unnamedplus"

vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

vim.o.number = true

vim.o.mousescroll = "ver:1,hor:1"

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 4

vim.g.python_indent = {
	disable_parentheses_indenting = false,
	closed_paren_align_last_line = false,
	searchpair_timeout = 150,
	continue = "shiftwidth()",
	open_paren = "shiftwidth()",
	nested_paren = "shiftwidth()",
}

vim.g.loaded_sql_completion = 1
vim.g.omni_sql_default_compl_type = "syntax"
vim.g.omni_sql_no_default_maps = 1

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

if os.getenv("TERM_PROGRAM") == "WezTerm" then
	local group = vim.api.nvim_create_augroup("wezterm", {})
	set_user_var("NEOVIM", "true")
	vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TabEnter", "BufLeave", "WinLeave", "TabLeave" }, {
		callback = function()
			vim.defer_fn(function()
				set_user_var("NEOVIM_FILE", vim.fn.expand("%:t"))
			end, 50)
		end,
		group = group,
	})
	vim.api.nvim_create_autocmd("ExitPre", {
		callback = function()
			set_user_var("NEOVIM", "false")
		end,
		group = group,
	})
end

(function()
	-- TODO: make this a plugin
	vim.opt.number = true
	vim.opt.relativenumber = true
	local excluded_filetypes = {
		["neo-tree"] = true,
		["snacks_terminal"] = true,
		["codecompanion"] = true,
	}
	local function set_relative(relative)
		if excluded_filetypes[vim.bo.filetype] then
			vim.opt.number = false
			vim.opt.relativenumber = false
			return
		end
		vim.opt.number = true
		vim.opt.relativenumber = relative
	end
	local relnum_group = vim.api.nvim_create_augroup("relnum", { clear = true })
	vim.api.nvim_create_autocmd({ "VimEnter", "BufNewFile", "BufReadPost" }, {
		group = relnum_group,
		callback = function()
			set_relative(true)
		end,
	})
	vim.api.nvim_create_autocmd("ModeChanged", {
		group = relnum_group,
		pattern = "*:i",
		callback = function()
			set_relative(false)
		end,
	})
	vim.api.nvim_create_autocmd("ModeChanged", {
		group = relnum_group,
		pattern = "i:*",
		callback = function()
			set_relative(true)
		end,
	})
	vim.api.nvim_create_autocmd("BufEnter", {
		group = relnum_group,
		callback = function()
			local mode = vim.api.nvim_get_mode()["mode"]
			if mode == "i" then
				set_relative(false)
			else
				set_relative(true)
			end
		end,
	})
end)()

require("lze").register_handlers(require("lzextras").lsp)

local key2spec = require("lzextras").key2spec

require("lze").load({
	"catppuccin",
	lazy = false,
	after = function()
		require("catppuccin").setup({
			flavour = "mocha",
			transparent_background = true,
		})
		vim.cmd.colorscheme("catppuccin")
	end,
})

require("lze").load({
	"fidget.nvim",
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
})

require("lze").load({
	"mini.nvim",
	event = "DeferredUIEnter",
	on_require = { "mini.icons" },
	after = function()
		require("mini.pairs").setup()
		require("mini.icons").setup()
		require("mini.tabline").setup()
		require("mini.statusline").setup()
		require("mini.jump2d").setup()
		require("mini.jump").setup()
		require("mini.ai").setup()
		require("mini.comment").setup()
		require("mini.surround").setup()
	end,
})

require("lze").load({
	"snacks",
	event = "DeferredUIEnter",
	keys = {
		key2spec("n", "<leader>ft", function()
			require("snacks").terminal.toggle()
		end, { desc = "Open Terminal" }),
		key2spec("n", "<leader>pp", function()
			require("snacks").toggle.profiler()
		end, { desc = "Toggle Profiler" }),
		key2spec("n", "<leader>ph", function()
			require("snacks").toggle.profiler_highlights()
		end, { desc = "Toggle Profiler Highlights" }),
	},
	after = function()
		local snacks = require("snacks")
		snacks.setup({})
	end,
})

require("lze").load({
	"edgy",
	event = "DeferredUIEnter",
	after = function()
		require("edgy").setup({
			bottom = {
				{
					ft = "snacks_terminal",
					size = { height = 0.3 },
					-- exclude floating windows
					filter = function(_, win)
						return vim.api.nvim_win_get_config(win).relative == ""
					end,
				},
			},
			left = {
				{
					title = "Neo-Tree",
					ft = "neo-tree",
					filter = function(buf)
						return vim.b[buf].neo_tree_source == "filesystem"
					end,
				},
			},
			right = {
				{
					title = "CodeCompanion chat",
					ft = "codecompanion",
					size = { width = 0.25 },
				},
			},
		})
	end,
})

require("lze").load({
	"flatten",
	event = "DeferredUIEnter",
	after = function()
		require("flatten").setup({})
	end,
})

require("lze").load({
	{
		"nvim-lspconfig",
		-- the on require handler will be needed if you want to use the
		-- fallback method of getting filetypes if you don't provide any
		on_require = { "lspconfig" },
		-- define a function to run over all type(plugin.lsp) == table
		-- when their filetype trigger loads them
		lsp = function(plugin)
			require("lspconfig")[plugin.name].setup(vim.tbl_extend("force", {
				on_attach = function(_, bufnr)
					-- thanks to https://github.com/BirdeeHub/nixCats-nvim/blob/142b95e/templates/home-manager/init.lua#L617
					local nmap = function(keys, func, desc)
						if desc then
							desc = "LSP: " .. desc
						end
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
					end
					nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

					nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

					nmap("gr", function()
						require("fzf-lua").lsp_references()
					end, "[G]oto [R]eferences")
					nmap("gI", function()
						require("fzf-lua").lsp_implementations()
					end, "[G]oto [I]mplementation")
					nmap("<leader>ds", function()
						require("fzf-lua").lsp_document_symbols()
					end, "[D]ocument [S]ymbols")
					nmap("<leader>ws", function()
						require("fzf-lua").lsp_workspace_symbols()
					end, "[W]orkspace [S]ymbols")

					nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")

					-- See `:help K` for why this keymap
					nmap("K", vim.lsp.buf.hover, "Hover Documentation")
					nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

					-- Lesser used LSP functionality
					nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
					nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
					nmap("<leader>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, "[W]orkspace [L]ist Folders")

					-- Create a command `:Format` local to the LSP buffer
					vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
						vim.lsp.buf.format()
					end, { desc = "Format current buffer with LSP" })
				end,
			}, plugin.lsp or {}))
		end,
	},
	{
		"basedpyright",
		lsp = {},
	},
	{
		"ruff",
		lsp = {},
	},
	{
		"ts_ls",
		lsp = {
			cmd = { "bunx", "--bun", "typescript-language-server", "--stdio" },
		},
	},
	{
		"svelte",
		lsp = {},
	},
	{
		"lua_ls",
		lsp = {},
	},
})

require("lze").load({
	"nvim-treesitter",
	event = "DeferredUIEnter",
	after = function()
		require("nvim-treesitter.configs").setup({
			highlight = { enable = true },
		})
	end,
})

require("lze").load({
	"blink.cmp",
	event = "DeferredUIEnter",
	on_require = "blink",
	after = function()
		require("blink.cmp").setup({
			keymap = {
				preset = "super-tab",
			},
			completion = {
				menu = {
					draw = {
						components = {
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
									return kind_icon
								end,
								-- Optionally, you may also use the highlights from mini.icons
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
						},
					},
				},
			},
		})
	end,
})

require("lze").load({
	"neo-tree",
	lazy = false, -- neo-tree does its own lazy loading
	after = function()
		local function on_move(data)
			require("snacks").rename.on_rename_file(data.source, data.destination)
		end
		local events = require("neo-tree.events")

		require("neo-tree").setup({
			event_handlers = {
				{ event = events.FILE_MOVED, handler = on_move },
				{ event = events.FILE_RENAMED, handler = on_move },
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
})

require("lze").load({
	"fzf-lua",
	event = "DeferredUIEnter",
	keys = {
		key2spec("n", "<leader>f\\", require("fzf-lua").buffers),
		key2spec("n", "<leader>fk", require("fzf-lua").builtin),
		key2spec("n", "<leader>fp", require("fzf-lua").files),
		key2spec("n", "<leader>fg", require("fzf-lua").live_grep_glob),
		key2spec("n", "<leader>fG", require("fzf-lua").lgrep_curbuf),
		-- key2spec("n", "<leader>fs", require("fzf-lua").lsp_workspace_symbols),
		-- key2spec("n", "<leader>fS", require("fzf-lua").lsp_document_symbols),
		key2spec("n", "<F1>", require("fzf-lua").help_tags),
	},
	after = function()
		require("fzf-lua").setup({})
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
})

require("lze").load({
	"hardtime",
	event = "DeferredUIEnter",
	after = function()
		require("hardtime").setup({
			disable_mouse = false,
			restriction_mode = "block",
			disabled_keys = {
				["<Up>"] = {},
				["<Down>"] = {},
				["<Left>"] = {},
				["<Right>"] = {},
			},
			restricted_keys = {
				["<Up>"] = { "n", "x" },
				["<Down>"] = { "n", "x" },
				["<Left>"] = { "n", "x" },
				["<Right>"] = { "n", "x" },
			},
		})
	end,
})

require("lze").load({
	"AniMotion",
	event = "DeferredUIEnter",
	after = function()
		require("AniMotion").setup({})
	end,
})

require("lze").load({
	"git-conflict",
	event = "DeferredUIEnter",
	after = function()
		require("git-conflict").setup({})
	end,
})

require("lze").load({
	"render-markdown",
	ft = { "markdown" },
	cmd = { "RenderMarkdown" },
	after = function()
		require("render-markdown").setup({})
	end,
})

require("lze").load({
	"image",
	ft = { "markdown" },
	after = function()
		require("image").setup({
			backend = "kitty",
			processor = "magick_cli",
			integrations = {
				markdown = {
					only_render_image_at_cursor = true,
				},
			},
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge, -- this is necessary for a good experience
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		})
	end,
})

require("lze").load({
	"molten",
	event = "BufEnter *.ipynb",
	after = function()
		vim.cmd("runtime! plugin/rplugin.vim")
		vim.cmd("silent! UpdateRemotePlugins")
		vim.g.molten_image_provider = "image.nvim"
	end,
})

require("lze").load({
	"jupytext",
	event = "DeferredUIEnter",
	after = function()
		require("jupytext").setup({
			format = "qmd",
			filetype = function(_, format, metadata)
				if format == "markdown" then
					return format
				elseif format == "qmd" then
					return "markdown"
				elseif format == "ipynb" then
					return "json"
				elseif format:sub(1, 2) == "md" then
					return "markdown"
				elseif format:sub(1, 3) == "Rmd" then
					return "markdown"
				else
					if metadata and metadata.kernelspec then
						return metadata.kernelspec.language
					else
						return ""
					end
				end
			end,
		})
	end,
})

require("lze").load({
	"otter",
	event = "DeferredUIEnter",
	after = function()
		require("otter").setup({})
	end,
})

require("lze").load({
	"quarto",
	event = "DeferredUIEnter",
	after = function()
		require("quarto").setup({
			lspFeatures = {
				enabled = true,
				chunks = "all",
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			codeRunner = {
				enabled = true,
				default_method = "molten",
			},
		})
	end,
})

require("lze").load({
	"orgmode",
	event = "DeferredUIEnter",
	dep_of = { "org-roam" },
	after = function()
		require("orgmode").setup({
			org_agenda_files = "~/notes/**/*",
			org_default_notes_file = "~/notes/refile.org",
			org_startup_folded = "inherit",
			org_todo_keywords = { "TODO", "STARTED", "|", "DONE", "CANCELED" },
		})
	end,
})

require("lze").load({
	"org-roam",
	event = "DeferredUIEnter",
	after = function()
		require("org-roam").setup({
			directory = "~/notes/",
		})
	end,
})

require("lze").load({
	"codecompanion",
	cmd = "CodeCompanion",
	keys = {
		key2spec({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true }),
		key2spec(
			{ "n", "v" },
			"<LocalLeader>a",
			"<cmd>CodeCompanionChat Toggle<cr>",
			{ noremap = true, silent = true }
		),
		key2spec("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true }),
	},
	after = function()
		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "localai",
				},
				inline = {
					adapter = "localai",
				},
			},
			adapters = {
				localai = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						env = {
							url = "http://localhost:2000",
						},
						schema = {
							model = {
								default = "gpt-qwen", -- define llm model to be used
							},
							temperature = {
								order = 2,
								mapping = "parameters",
								type = "number",
								optional = true,
								default = 0.8,
								desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
								validate = function(n)
									return n >= 0 and n <= 2, "Must be between 0 and 2"
								end,
							},
							max_completion_tokens = {
								order = 3,
								mapping = "parameters",
								type = "integer",
								optional = true,
								default = nil,
								desc = "An upper bound for the number of tokens that can be generated for a completion.",
								validate = function(n)
									return n > 0, "Must be greater than 0"
								end,
							},
							stop = {
								order = 4,
								mapping = "parameters",
								type = "string",
								optional = true,
								default = nil,
								desc = "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
								validate = function(s)
									return s:len() > 0, "Cannot be an empty string"
								end,
							},
							logit_bias = {
								order = 5,
								mapping = "parameters",
								type = "map",
								optional = true,
								default = nil,
								desc = "Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.",
								subtype_key = {
									type = "integer",
								},
								subtype = {
									type = "integer",
									validate = function(n)
										return n >= -100 and n <= 100, "Must be between -100 and 100"
									end,
								},
							},
						},
					})
				end,
			},
		})

		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,
})

require("lze").load({
	"tiny-inline-diagnostic.nvim",
	event = "LspAttach",
	after = function()
		require("tiny-inline-diagnostic").setup({
			preset = "classic",
			transparent_bg = true,
			transparent_cursorline = true,
			hi = {
				background = "None",
			},
		})
		vim.diagnostic.config({ virtual_text = false })
	end,
})
