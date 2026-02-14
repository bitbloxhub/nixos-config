---@diagnostic disable: missing-fields
-- Pull in the wezterm API
local wezterm = require("wezterm") --[[@as Wezterm]]
local resurrect = require("resurrect")

-- This will hold the configuration.
local config = wezterm.config_builder()

function string.starts(str, start)
	return str.sub(str, 1, str.len(start)) == start
end

local function frexp(x)
	if x == 0 then
		return 0, 0
	end
	local e = math.floor(math.log(math.abs(x)) / math.log(2) + 1)
	return x / 2 ^ e, e
end

local function to_binary(num, bits)
	-- returns a table of bits, most significant first.
	bits = bits or math.max(1, select(2, frexp(num)))
	local t = {} -- will contain the bits
	for b = bits, 1, -1 do
		t[b] = math.fmod(num, 2)
		num = math.floor((num - t[b]) / 2)
	end
	return t
end

--- Encode binary from to_binary into zero width unicode characters
---@param bin table
---@return string
local function zero_width_encode(bin)
	local zero_width = ""
	for _, digit in ipairs(bin) do
		if digit == 0 then
			zero_width = zero_width .. "\u{200c}"
		else
			zero_width = zero_width .. "\u{200d}"
		end
	end
	return zero_width
end

--- Sends a message to niri and gets the result
---@param msg string
---@return table
local function niri_msg(msg)
	local proc = assert(io.popen("niri msg --json " .. msg))
	local text = proc:read("*all")
	proc:close()
	local parsed = wezterm.json_parse(text)
	return parsed
end

local function get_niri_wezterm_window_by_id(id)
	local niri_windows = niri_msg("windows")
	for _, win in ipairs(niri_windows) do
		if win.app_id == "org.wezfurlong.wezterm" then
			if win.title:starts(zero_width_encode(to_binary(id, 8))) then
				return win
			end
		end
	end
end

---@param pane_tree pane_tree
---@param modifier fun(pane_tree: pane_tree): pane_tree
---@return pane_tree
local function walk_pane_tree(pane_tree, modifier)
	if type(pane_tree.top) == "table" then
		---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
		pane_tree.top = modifier(walk_pane_tree(pane_tree.top, modifier))
	end
	if type(pane_tree.bottom) == "table" then
		---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
		pane_tree.bottom = modifier(walk_pane_tree(pane_tree.bottom, modifier))
	end
	if type(pane_tree.left) == "table" then
		---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
		pane_tree.left = modifier(walk_pane_tree(pane_tree.left, modifier))
	end
	if type(pane_tree.right) == "table" then
		---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
		pane_tree.right = modifier(walk_pane_tree(pane_tree.right, modifier))
	end
	return modifier(pane_tree)
end

-- Better session restore for niri
if os.getenv("XDG_CURRENT_DESKTOP") == "niri" and not os.getenv("TERMFILECHOOSER") then
	--- Save the workspace index for niri in the window data
	---@param current_state window_state
	---@param window MuxWindow
	---@return window_state
	resurrect.window_state.save_hook = function(current_state, window)
		local niri_workspaces = niri_msg("workspaces")
		local niri_wezterm_window = get_niri_wezterm_window_by_id(window:gui_window():window_id())
		local workspace_idx = nil
		for _, workspace in ipairs(niri_workspaces) do
			if workspace.id == niri_wezterm_window.workspace_id then
				workspace_idx = workspace.idx
				break
			end
		end
		---@diagnostic disable-next-line: inject-field
		current_state.workspace_idx = workspace_idx
		return current_state
	end

	--- Move the window to the right workspace
	---@param state window_state
	---@param window MuxWindow
	resurrect.window_state.post_restore_hook = function(state, window)
		wezterm.time.call_after(0.5, function()
			os.execute(
				"niri msg action move-window-to-workspace --focus false --window-id "
					.. get_niri_wezterm_window_by_id(window:gui_window():window_id()).id
					.. " "
					---@diagnostic disable-next-line: undefined-field
					.. state.workspace_idx
			)
		end)
	end

	--- Sort windows by their workspace index
	---@param current_state workspace_state
	---@return workspace_state
	resurrect.workspace_state.save_hook = function(current_state)
		table.sort(current_state.window_states, function(a, b)
			---@diagnostic disable-next-line: undefined-field
			return a.workspace_idx < b.workspace_idx
		end)
		return current_state
	end
end

--- Use resession to restore neovim tabs
---@param current_state tab_state
---@param tab MuxTab
---@return tab_state
resurrect.tab_state.save_hook = function(current_state, tab)
	current_state.pane_tree = walk_pane_tree(current_state.pane_tree, function(pane_tree)
		if type(pane_tree.process) == "table" and pane_tree.process.name == "nvim" then
			pane_tree.process.executable = "nvim"
			pane_tree.process.argv = {
				"nvim",
				"-c",
				string.format(
					'lua require("resession").load("%s", {dir = "dirsession"})',
					pane_tree.process.cwd:gsub("/", "_"):gsub(":", "_")
				),
			}
		end
		return pane_tree
	end)
	return current_state
end

if not os.getenv("TERMFILECHOOSER") then
	resurrect.state_manager.periodic_save({
		interval_seconds = 60,
		save_workspaces = true,
		save_windows = true,
		save_tabs = true,
	})
	wezterm.on("gui-startup", function()
		local opts = {
			relative = true,
			restore_text = true,
			on_pane_restore = resurrect.tab_state.default_on_pane_restore,
		}
		local state = resurrect.state_manager.load_state("default", "workspace")
		resurrect.workspace_state.restore_workspace(state, opts)
	end)
else
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
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action_callback(function()
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
		end),
	},
	{
		key = "W",
		mods = "ALT",
		action = resurrect.window_state.save_window_action(),
	},
	{
		key = "T",
		mods = "ALT",
		action = resurrect.tab_state.save_tab_action(),
	},
	{
		key = "s",
		mods = "ALT",
		action = wezterm.action_callback(function()
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.window_state.save_window_action()
		end),
	},
	{
		key = "r",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extension
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.state_manager.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
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
wezterm.on("user-var-changed", function(window, pane)
	local vars = pane:get_user_vars()
	if vars.NEOVIM == "true" then
		window:active_tab():set_title(string.format("  %s", vars.NEOVIM_FILE))
	else
		window:active_tab():set_title(vars.WEZTERM_PROG)
	end
end)
---@param tab TabInformation
wezterm.on("format-window-title", function(tab)
	for _, win in ipairs(wezterm.gui.gui_windows()) do
		if win:window_id() == tab.window_id then
			local id_bin = to_binary(win:window_id(), 8)
			local id_zero_width = zero_width_encode(id_bin)
			return id_zero_width .. (tab.tab_title or "")
		end
	end
	return ""
end)
if os.getenv("XDG_CURRENT_DESKTOP") == "GNOME" then
	config.enable_wayland = false
end

config.enable_kitty_keyboard = true

-- and finally, return the configuration to wezterm
return config
