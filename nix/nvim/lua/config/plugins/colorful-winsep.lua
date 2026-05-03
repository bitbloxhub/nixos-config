return {
	"colorful-winsep",
	event = "WinLeave",
	after = function()
		require("colorful-winsep").setup({
			animate = {
				enabled = false,
			},
		})
	end,
}
