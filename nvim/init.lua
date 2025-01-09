-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local function set_user_var(key, value)
	io.write(string.format("\027]1337;SetUserVar=%s=%s\a", key, vim.base64.encode(tostring(value))))
end

-- Safely execute immediately
now(function()
	vim.o.termguicolors = true
	--vim.cmd('colorscheme randomhue')
	add({ source = "catppuccin/nvim" })
	require("catppuccin").setup({
		flavour = "mocha",
		transparent_background = true,
	})
	vim.cmd.colorscheme("catppuccin")
end)
now(function()
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
end)
now(function()
	add({ source = "j-hui/fidget.nvim" })
	local fidget = require("fidget")
	fidget.setup({
		notification = {
			override_vim_notify = true,
			window = {
				winblend = 0,
			},
		},
	})
end)
now(function()
	require("mini.pairs").setup()
end)
now(function()
	require("mini.icons").setup()
end)
now(function()
	require("mini.tabline").setup()
end)
now(function()
	require("mini.statusline").setup()
end)
now(function()
	require("mini.jump2d").setup()
end)
now(function()
	require("mini.jump").setup()
end)
now(function()
	vim.o.expandtab = false
	vim.o.tabstop = 4
	vim.o.softtabstop = 4
	vim.o.shiftwidth = 4
	vim.o.number = true
	vim.o.mousescroll = "ver:1,hor:1"
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
end)
now(function()
	add({ source = "neovim/nvim-lspconfig" })
	local lspconfig = require("lspconfig")
	lspconfig.basedpyright.setup({})
	lspconfig.ts_ls.setup({
		cmd = { "bunx", "--bun", "typescript-language-server", "--stdio" },
	})
	lspconfig.svelte.setup({}) -- unfortunately using bun does not work
	lspconfig.lua_ls.setup({})
end)
now(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- Use 'master' while monitoring updates in 'main'
		checkout = "master",
		monitor = "main",
		-- Perform action after every checkout
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
	-- Possible to immediately execute code which depends on the added plugin
	require("nvim-treesitter.configs").setup({
		ensure_installed = { "lua", "vimdoc" },
		highlight = { enable = true },
	})
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	vim.opt.foldcolumn = "0"
	vim.opt.foldtext = ""
	vim.opt.foldlevel = 99
	vim.opt.foldlevelstart = 99
	vim.opt.foldnestmax = 4
end)
now(function()
	local function build_blink(params)
		vim.notify("Building blink.cmp", vim.log.levels.INFO)
		local obj = vim.system({ "cargo", "build", "--release" }, { cwd = params.path }):wait()
		if obj.code == 0 then
			vim.notify("Building blink.cmp done", vim.log.levels.INFO)
		else
			vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
		end
	end
	add({
		source = "Saghen/blink.cmp",
		depends = {
			"rafamadriz/friendly-snippets",
		},
		hooks = {
			post_install = build_blink,
			post_checkout = build_blink,
		},
	})
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
	require("blink.cmp")
end)
now(function()
	add({ source = "direnv/direnv.vim" })
end)
now(function()
	add({
		source = "nvim-neo-tree/neo-tree.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
	})
	require("neo-tree").setup({
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
end)
now(function()
	add({ source = "ibhagwan/fzf-lua" })
	require("fzf-lua").setup({})
end)
now(function()
	add({ source = "MeanderingProgrammer/render-markdown.nvim" })
	require("render-markdown").setup({})
end)
now(function()
	add({ source = "3rd/image.nvim" })
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
end)
now(function()
	add({ source = "folke/snacks.nvim" })
	local snacks = require("snacks")
	snacks.setup({})
	vim.keymap.set("n", "<leader>ft", function()
		snacks.terminal.toggle()
	end, { desc = "Open Terminal" })
	vim.cmd("command Z w | qa")
	vim.cmd("cabbrev wqa Z")
end)
now(function()
	add({ source = "folke/edgy.nvim" })
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
	})
end)
now(function()
	add({ source = "willothy/flatten.nvim" })
	require("flatten").setup({})
end)
now(function()
	add({
		source = "benlubas/molten-nvim",
		hooks = {
			post_checkout = function()
				vim.cmd("UpdateRemotePlugins")
			end,
		},
	})
	vim.g.molten_image_provider = "image.nvim"
end)
now(function()
	add({ source = "goerz/jupytext.nvim" })
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
end)
now(function()
	add({ source = "jmbuhr/otter.nvim" })
	require("otter").setup()
end)
now(function()
	add({ source = "quarto-dev/quarto-nvim" })
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
end)
-- Safely execute later
later(function()
	require("mini.ai").setup()
end)
later(function()
	require("mini.comment").setup()
end)
later(function()
	require("mini.pick").setup()
end)
later(function()
	require("mini.surround").setup()
end)
