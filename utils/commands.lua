#!nvim.exe --clean --headless -l

local M = {}

---@param status status
---@param settings client_settings
function M.general_indicator(status, settings)
	local data = settings.default
		or {
			label = "",
			label_alt = "",
			on_left = "",
			on_right = "",
			on_middle = "",
		}

	for _, v in ipairs(settings.priority) do
		if status[v] then
			data.label = data.label .. " " .. settings.indicators[v].label
			data.label_alt = data.label_alt .. " " .. settings.indicators[v].label_alt
		end
	end

	for _, v in ipairs(settings.priority) do
		if status[v] then
			data.on_left = settings.indicators[v].on_left
			data.on_right = settings.indicators[v].on_right
			data.on_middle = settings.indicators[v].on_middle
			break
		end
	end

	io.write(vim.json.encode(data))
end

return M
