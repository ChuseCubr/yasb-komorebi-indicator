local M = {}

---@param state table
---@return status
function M.get_status(state)
	---@type status
	local status = {
		floating = false,
		stacked = false,
		monocle = false,
		maximized = false,
	}

	local monitor = state.monitors.elements[state.monitors.focused + 1]
	local workspace = monitor.workspaces.elements[monitor.workspaces.focused + 1]

	if workspace.floating_windows ~= vim.NIL and #workspace.floating_windows > 0 then
		status.floating = true
	end

	if #workspace.containers.elements > 0 then
		local container = workspace.containers.elements[workspace.containers.focused + 1]
		if container and #container.windows.elements > 1 then
			status.stacked = true
		end
	end

	if workspace.monocle_container ~= vim.NIL then
		status.monocle = true
	end

	if workspace.maximized_window ~= vim.NIL then
		status.maximized = true
	end

	return status
end

return M
