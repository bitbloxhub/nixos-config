--- From https://yazi-rs.github.io/docs/tips/#symlink-in-status
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

require("git"):setup()

require("relative-motions"):setup({ show_numbers = "relative", show_motion = true, enter_mode = "first" })
