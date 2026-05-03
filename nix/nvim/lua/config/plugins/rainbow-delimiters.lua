return {
	"rainbow-delimiters",
	event = "DeferredUIEnter",
	after = function()
		require("rainbow-delimiters.setup").setup({})
	end,
}
