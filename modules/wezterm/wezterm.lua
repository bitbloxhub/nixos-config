---@diagnostic disable: missing-fields
-- Pull in the wezterm API
local wezterm = require("wezterm") --[[@as Wezterm]]

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("Fira Code")
config.font_size = 12
config.background = {
	{
		source = { File = "/home/jonahgam/miku-hacker0.jpg" },
	},
	{
		---@diagnostic disable-next-line: assign-type-mismatch
		source = { Color = "#1e1e2e" },
		opacity = 0.9,
		width = "100%",
		height = "100%",
	},
}
config.use_fancy_tab_bar = false
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.colors = {
	tab_bar = {
		background = "rgba(0,0,0,0)",
	},
}
config.tab_bar_at_bottom = true
config.tab_max_width = 40
config.alternate_buffer_wheel_scroll_speed = 1
local act = wezterm.action
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "NONE",
		action = act.ScrollByLine(-1),
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "NONE",
		action = act.ScrollByLine(1),
	},
}
wezterm.on("user-var-changed", function(window, pane)
	local vars = pane:get_user_vars()
	if vars.NEOVIM == "true" then
		window:active_tab():set_title(string.format("  %s", vars.NEOVIM_FILE))
	else
		window:active_tab():set_title(vars.WEZTERM_PROG)
	end
end)
wezterm.on("format-window-title", function(tab)
	---@diagnostic disable-next-line
	return tab.tab_title
end)
config.enable_wayland = false

-- and finally, return the configuration to wezterm
return config
