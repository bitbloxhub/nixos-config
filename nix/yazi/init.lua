--- From https://yazi-rs.github.io/docs/tips/#symlink-in-status
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

---@diagnostic disable-next-line: inject-field
th.git = th.git or {}
th.git.ignored_sign = " "
th.git.untracked_sign = " "
th.git.modified_sign = " "
th.git.added_sign = " "
th.git.deleted_sign = " "
th.git.updated_sign = " "

require("git"):setup()

require("relative-motions"):setup({ show_numbers = "relative", show_motion = true, enter_mode = "first" })
