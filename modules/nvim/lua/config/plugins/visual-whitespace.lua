return {
	"visual-whitespace",
	event = "DeferredUIEnter",
	after = function()
		require("visual-whitespace").setup({})
	end,
}
