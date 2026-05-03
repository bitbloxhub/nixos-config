return {
	"hardtime",
	event = "DeferredUIEnter",
	after = function()
		require("hardtime").setup({
			disable_mouse = false,
			restriction_mode = "block",
		})
	end,
}
