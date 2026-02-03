---@diagnostic disable: missing-fields

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
vim.o.guicursor = "n-v-c-sm-t:block,i-ci-ve:ver25,r-cr-o:hor20"

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

---Workaround for rust settings sometimes overriding .editorconfig,
---see https://github.com/neovim/neovim/issues/30334#issuecomment-2348238522
vim.g.rust_recommended_style = 0

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	desc = "Set recommended Rust style settings if no editorconfig is used",
	callback = function()
		if not vim.b.editorconfig then
			vim.cmd("setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab textwidth=99")
		end
	end,
})

require("lze").register_handlers(require("lzextras").lsp)

local key2spec = require("lzextras").key2spec

vim.env.NIXCATS_PACK_DIR = nixCats.vimPackDir

require("lze").load({
	"catppuccin-nvim",
	lazy = false,
	after = function()
		require("catppuccin").setup({
			flavour = "mocha",
			float = {
				transparent = true,
			},
			transparent_background = true,
			custom_highlights = function(C)
				local O = require("catppuccin").options
				-- old catppuccin styles
				return {
					["@variable.member"] = { fg = C.lavender }, -- For fields.
					["@module"] = { fg = C.lavender, style = O.styles.miscs or { "italic" } }, -- For identifiers referring to modules and namespaces.
					["@string.special.url"] = { fg = C.rosewater, style = { "italic", "underline" } }, -- urls, links and emails
					["@type.builtin"] = { fg = C.yellow, style = O.styles.properties or { "italic" } }, -- For builtin types.
					["@property"] = { fg = C.lavender, style = O.styles.properties or {} }, -- Same as TSField.
					["@constructor"] = { fg = C.sapphire }, -- For constructor calls and definitions: = { } in Lua, and Java constructors.
					["@keyword.operator"] = { link = "Operator" }, -- For new keyword operator
					["@keyword.export"] = { fg = C.sky, style = O.styles.keywords },
					["@markup.strong"] = { fg = C.maroon, style = { "bold" } }, -- bold
					["@markup.italic"] = { fg = C.maroon, style = { "italic" } }, -- italic
					["@markup.heading"] = { fg = C.blue, style = { "bold" } }, -- titles like: # Example
					["@markup.quote"] = { fg = C.maroon, style = { "bold" } }, -- block quotes
					["@markup.link"] = { link = "Tag" }, -- text references, footnotes, citations, etc.
					["@markup.link.label"] = { link = "Label" }, -- link, reference descriptions
					["@markup.link.url"] = { fg = C.rosewater, style = { "italic", "underline" } }, -- urls, links and emails
					["@markup.raw"] = { fg = C.teal }, -- used for inline code in markdown and for doc in python (""")
					["@markup.list"] = { link = "Special" },
					["@tag"] = { fg = C.mauve }, -- Tags like html tag names.
					["@tag.attribute"] = { fg = C.teal, style = O.styles.miscs or { "italic" } }, -- Tags like html tag names.
					["@tag.delimiter"] = { fg = C.sky }, -- Tag delimiter like < > /
					["@property.css"] = { fg = C.lavender },
					["@property.id.css"] = { fg = C.blue },
					["@type.tag.css"] = { fg = C.mauve },
					["@string.plain.css"] = { fg = C.peach },
					["@constructor.lua"] = { fg = C.flamingo }, -- For constructor calls and definitions: = { } in Lua.
					-- typescript
					["@property.typescript"] = { fg = C.lavender, style = O.styles.properties or {} },
					["@constructor.typescript"] = { fg = C.lavender },
					-- TSX (Typescript React)
					["@constructor.tsx"] = { fg = C.lavender },
					["@tag.attribute.tsx"] = { fg = C.teal, style = O.styles.miscs or { "italic" } },
					["@type.builtin.c"] = { fg = C.yellow, style = {} },
					["@type.builtin.cpp"] = { fg = C.yellow, style = {} },
				}
			end,
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
	keys = {
		key2spec("n", "<leader>bd", function()
			require("mini.bufremove").delete(vim.fn.bufnr(), false)
		end, { desc = "Closes the current buffer" }),
	},
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
		require("mini.bufremove").setup()
		require("mini.splitjoin").setup()
	end,
})

require("lze").load({
	"snacks",
	event = "DeferredUIEnter",
	keys = {
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
			left = {
				{
					title = "Neo-Tree",
					ft = "neo-tree",
					filter = function(buf)
						return vim.b[buf].neo_tree_source == "filesystem"
					end,
					open = function()
						require("neo-tree.command").execute({ action = "show", source = "filesystem" })
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
			vim.lsp.config(plugin.name, plugin.lsp or {})
			vim.lsp.enable(plugin.name)
		end,
		before = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					-- thanks to https://github.com/BirdeeHub/nixCats-nvim/blob/142b95e/templates/home-manager/init.lua#L617
					local nmap = function(keys, func, desc)
						if desc then
							desc = "LSP: " .. desc
						end
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
					end
					nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					nmap("<leader>ca", function()
						require("fzf-lua").lsp_code_actions()
					end, "[C]ode [A]ction")

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
					nmap("<M-k>", vim.lsp.buf.signature_help, "Signature Documentation")

					-- Lesser used LSP functionality
					nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
					nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
					nmap("<leader>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, "[W]orkspace [L]ist Folders")

					-- Create a command `:Format` local to the LSP buffer
					vim.api.nvim_buf_create_user_command(event.buf, "Format", function(_)
						vim.lsp.buf.format()
					end, { desc = "Format current buffer with LSP" })
				end,
			})
		end,
	},
	{
		"typos_lsp",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
	{
		"basedpyright",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
	{
		"ruff",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
	{
		"ts_ls",
		---@type vim.lsp.ClientConfig
		lsp = {
			single_file_support = false,
			---@diagnostic disable-next-line: assign-type-mismatch
			root_dir = function(bufnr, on_dir)
				local package_json_root = vim.fs.root(bufnr, "package.json")
				if package_json_root then
					on_dir(package_json_root)
				end
			end,
		},
	},
	{
		"denols",
		---@type vim.lsp.ClientConfig
		lsp = {
			---@diagnostic disable-next-line: assign-type-mismatch
			root_dir = function(bufnr, on_dir)
				if vim.fs.root(bufnr, "package.json") then
					-- Projects can have both package.json and deno.jsonc. If
					-- we have both, prefer ts_ls.
					return
				end
				on_dir(vim.fs.root(bufnr, { "deno.json", "deno.jsonc" }))
			end,
		},
	},
	{
		"svelte",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
	{
		"astro",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
	{
		"mdx_analyzer",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
	{
		"lua_ls",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
	{
		"rust_analyzer",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
	{
		"ts_query_ls",
		---@type vim.lsp.ClientConfig
		lsp = {
			init_options = {
				parser_install_directories = {
					nixCats.vimPackDir
						.. "/pack/myNeovimGrammars/start/vimplugin-treesitter-grammar-ALL-INCLUDED/parser",
					nixCats.extra.tree_sitter_orgmode_path .. "/lib/lua/5.1/parser/",
				},
			},
		},
	},
	{
		"gopls",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
})

require("lze").load({
	"nvim-treesitter",
	lazy = false,
	after = function()
		vim.filetype.add({
			extension = {
				mdx = "mdx",
			},
		})
		vim.treesitter.language.register("markdown", { "mdx" })

		-- From https://github.com/BirdeeHub/nixCats-nvim/blob/742da08/templates/example/lua/myLuaConf/plugins/treesitter.lua#L5-L44
		---@param buf integer
		---@param language string
		local function treesitter_try_attach(buf, language)
			-- check if parser exists and load it
			if not vim.treesitter.language.add(language) then
				return false
			end
			-- enables syntax highlighting and other treesitter features
			vim.treesitter.start(buf, language)

			-- enables treesitter based folds
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

			return true
		end

		local installable_parsers = require("nvim-treesitter").get_available()
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf, filetype = args.buf, args.match
				local language = vim.treesitter.language.get_lang(filetype)
				if not language then
					return
				end

				if not treesitter_try_attach(buf, language) then
					if vim.tbl_contains(installable_parsers, language) then
						-- not already installed, so try to install them via nvim-treesitter if possible
						require("nvim-treesitter").install(language):await(function()
							treesitter_try_attach(buf, language)
						end)
					end
				end
			end,
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
	"neo-tree.nvim",
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
})

require("lze").load({
	"hardtime",
	event = "DeferredUIEnter",
	after = function()
		require("hardtime").setup({
			disable_mouse = false,
			restriction_mode = "block",
		})
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
	dep_of = { "molten" },
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

require("lze").load({
	"visual-whitespace",
	event = "DeferredUIEnter",
	after = function()
		require("visual-whitespace").setup({})
	end,
})

require("lze").load({
	"smear-cursor.nvim",
	event = "DeferredUIEnter",
	after = function()
		require("smear_cursor").setup({
			legacy_computing_symbols_support = false,
			smear_insert_mode = false,
		})
	end,
})

require("lze").load({
	"which-key.nvim",
	event = "DeferredUIEnter",
	after = function()
		require("which-key").setup()

		require("which-key").add({
			{ "<leader>f", group = "[F]zf-lua" },
		})
	end,
})

require("lze").load({
	"nvim-bqf",
	after = function()
		require("bqf").setup({
			preview = { winblend = 0 },
		})
	end,
})

require("lze").load({
	"quicker.nvim",
	event = "DeferredUIEnter",
	after = function()
		require("quicker").setup()
	end,
})

require("lze").load({
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
		require("resession").setup({
			extensions = {
				edgy = {
					enable_in_tab = true,
				},
			},
		})
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
})
