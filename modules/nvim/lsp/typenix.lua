---@type vim.lsp.Config
return {
	cmd = function(dispatchers)
		local cmd = "typenix"
		return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
	end,
	root_markers = { "flake.nix", ".git" },
	filetypes = {
		"nix",
		"nixts",
	},
}
