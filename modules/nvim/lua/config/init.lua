local function set_user_var(key, value)
	io.write(string.format("\027]1337;SetUserVar=%s=%s\a", key, vim.base64.encode(tostring(value))))
end

vim.o.termguicolors = true
vim.o.guicursor = "n-v-c-sm-t:block,i-ci-ve:ver25,r-cr-o:hor20"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.clipboard = "unnamedplus"

-- Tabs
vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

vim.o.number = true

vim.o.mousescroll = "ver:1,hor:1"

-- Folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 4

-- Python tab configuration
vim.g.python_indent = {
	disable_parentheses_indenting = false,
	closed_paren_align_last_line = false,
	searchpair_timeout = 150,
	continue = "shiftwidth()",
	open_paren = "shiftwidth()",
	nested_paren = "shiftwidth()",
}

-- Disables unneeded features that slow down SQL editing
vim.g.loaded_sql_completion = 1
vim.g.omni_sql_default_compl_type = "syntax"
vim.g.omni_sql_no_default_maps = 1

-- Neo-tree hijack
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

vim.o.laststatus = 3 -- Global statusline

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

-- For lua-language-server
vim.env.NVIM_PACK_DIR = require("nix-info").vim_pack_dir;
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
	local relnum_group = vim.api.nvim_create_augroup("relativity", { clear = true })
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

require("lze").load({
	{ import = "config.plugins.blink-indent" },
	{ import = "config.plugins.bufferline" },
	{ import = "config.plugins.catppuccin" },
	{ import = "config.plugins.codecompanion" },
	{ import = "config.plugins.codediff" },
	{ import = "config.plugins.colorful-winsep" },
	{ import = "config.plugins.fidget" },
	{ import = "config.plugins.fzf" },
	{ import = "config.plugins.gitsigns" },
	{ import = "config.plugins.hardtime" },
	{ import = "config.plugins.image" },
	{ import = "config.plugins.incline" },
	{ import = "config.plugins.lsp" },
	{ import = "config.plugins.mini" },
	{ import = "config.plugins.neo-tree" },
	{ import = "config.plugins.noice" },
	{ import = "config.plugins.org-mode" },
	{ import = "config.plugins.quickfix" },
	{ import = "config.plugins.rainbow-delimiters" },
	{ import = "config.plugins.render-markdown" },
	{ import = "config.plugins.resession" },
	{ import = "config.plugins.textobjects" },
	{ import = "config.plugins.tree-sitter" },
	{ import = "config.plugins.visual-whitespace" },
	{ import = "config.plugins.which-key" },
	{ import = "config.plugins.yazi" },
})
