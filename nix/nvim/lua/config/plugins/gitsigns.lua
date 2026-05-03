return {
	"gitsigns",
	event = "DeferredUIEnter",
	after = function()
		require("gitsigns").setup({})
	end,
}
