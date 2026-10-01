---@diagnostic disable: missing-fields
-- Pull in the wezterm API
local wezterm = require("wezterm") --[[@as Wezterm]]

-- This will hold the configuration.
local config = wezterm.config_builder()

if os.getenv("TERMFILECHOOSER") then
	config.hide_tab_bar_if_only_one_tab = true
end

config.default_prog = { "nu" }
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("Fira Code")
config.font_size = 12
config.background = {
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
config.keys = {
	-- kitty delete fix for neovim https://github.com/wezterm/wezterm/discussions/3758#discussioncomment-12096192
	{
		key = "Delete",
		mods = "NONE",
		action = wezterm.action.SendString("\x1b[3~"),
	},
}
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
if os.getenv("XDG_CURRENT_DESKTOP") == "GNOME" then
	config.enable_wayland = false
end

config.enable_kitty_keyboard = true

-- and finally, return the configuration to wezterm
return config
