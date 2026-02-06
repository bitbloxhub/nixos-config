return {
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
		dep_of = { "nvim-lsp-file-operations" },
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
					nmap("<leader>fws", function()
						require("fzf-lua").lsp_workspace_symbols()
					end, "[W]orkspace [S]ymbols")

					nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")

					-- See `:help K` for why this keymap
					nmap("K", vim.lsp.buf.hover, "Hover Documentation")
					nmap("<M-k>", vim.lsp.buf.signature_help, "Signature Documentation")

					-- Lesser used LSP functionality
					nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					nmap("<leader>lwa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
					nmap("<leader>lwr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
					nmap("<leader>lwl", function()
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
		"otter",
		event = "DeferredUIEnter",
		after = function()
			require("otter").setup({})
		end,
	},
	{
		"blink.cmp",
		event = "DeferredUIEnter",
		on_require = "blink",
		after = function()
			require("blink.cmp").setup({
				keymap = {
					preset = "super-tab",
				},
				cmdline = {
					enabled = false,
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
	},
	{
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
	},
	{
		"nvim-lsp-file-operations",
		event = "DeferredUIEnter",
		after = function()
			require("lsp-file-operations").setup({})
		end,
	},
	{
		"nvim-navic",
		event = "DeferredUIEnter",
		after = function()
			require("nvim-navic").setup({
				lsp = {
					auto_attach = true,
				},
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
					require("nix-info").vim_pack_dir
						.. "/pack/myNeovimGrammars/start/vimplugin-treesitter-grammar-ALL-INCLUDED/parser",
					require("nix-info").settings.tree_sitter_orgmode_path .. "/lib/lua/5.1/parser/",
				},
			},
		},
	},
	{
		"gopls",
		---@type vim.lsp.ClientConfig
		lsp = {},
	},
}
