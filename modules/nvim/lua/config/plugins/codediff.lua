return {
	"codediff.nvim",
	cmd = "CodeDiff",
	after = function()
		-- TODO: dont show [No Name] buffers after CodeDiff closing
		require("codediff").setup({})
	end,
}
