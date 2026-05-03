return {
	"render-markdown",
	ft = { "markdown" },
	cmd = { "RenderMarkdown" },
	after = function()
		require("render-markdown").setup({})
	end,
}
