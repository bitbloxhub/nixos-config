return {
	"image",
	ft = { "markdown" },
	after = function()
		require("image").setup({
			backend = "kitty",
			processor = "magick_cli",
			integrations = {
				typst = {
					enabled = false,
				},
			},
		})
	end,
}
