return {
	"neorepl.nvim",
	event = "DeferredUIEnter",
	after = function()
		require("neorepl").config({})
	end,
}
