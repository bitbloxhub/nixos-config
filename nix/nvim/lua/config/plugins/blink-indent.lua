return {
	"blink.indent",
	event = "DeferredUIEnter",
	after = function()
		require("blink.indent").setup({})
	end,
}
