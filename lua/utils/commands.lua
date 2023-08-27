local M = {}

---@alias command "status" | indicator

---@param status status
---@param settings client_settings
function M.status(status, settings)
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
			data.label = data.label .. " " .. settings.indicators[v].on.label
			data.label_alt = data.label_alt .. " " .. settings.indicators[v].on.label_alt
		end
	end

	for _, v in ipairs(settings.priority) do
		if status[v] then
			data.on_left = settings.indicators[v].on.on_left
			data.on_right = settings.indicators[v].on.on_right
			data.on_middle = settings.indicators[v].on.on_middle
			break
		end
	end

	io.write(vim.json.encode(data))
end

---@param status status
---@param settings client_settings
function M.statuses(status, settings)
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
			data.label = data.label .. " " .. settings.indicators[v].on.label
			data.label_alt = data.label_alt .. " " .. settings.indicators[v].on.label_alt
		else
			data.label = data.label .. " " .. settings.indicators[v].off.label
			data.label_alt = data.label_alt .. " " .. settings.indicators[v].off.label_alt
		end
	end

	for _, v in ipairs(settings.priority) do
		if status[v] then
			data.on_left = settings.indicators[v].on.on_left
			data.on_right = settings.indicators[v].on.on_right
			data.on_middle = settings.indicators[v].on.on_middle
			break
		end
	end

	io.write(vim.json.encode(data))
end

---@param status status
---@param settings client_settings
---@param mode indicator
local function indiv_status(status, settings, mode)
	local data = settings.default
		or {
			label = "",
			label_alt = "",
			on_left = "",
			on_right = "",
			on_middle = "",
		}

	local indicator = settings.indicators[mode]
	if status[mode] then
		data.label = data.label .. " " .. indicator.on.label
		data.label_alt = data.label_alt .. " " .. indicator.on.label_alt
		data.on_left = indicator.on.on_left
		data.on_right = indicator.on.on_right
		data.on_middle = indicator.on.on_middle
	else
		data.label = data.label .. " " .. indicator.off.label
		data.label_alt = data.label_alt .. " " .. indicator.off.label_alt
		data.on_left = indicator.off.on_left
		data.on_right = indicator.off.on_right
		data.on_middle = indicator.off.on_middle
	end

	io.write(vim.json.encode(data))
end

---@param status status
---@param settings client_settings
function M.floating(status, settings)
	indiv_status(status, settings, "floating")
end

---@param status status
---@param settings client_settings
function M.stacked(status, settings)
	indiv_status(status, settings, "stacked")
end

---@param status status
---@param settings client_settings
function M.monocle(status, settings)
	indiv_status(status, settings, "monocle")
end

---@param status status
---@param settings client_settings
function M.maximized(status, settings)
	indiv_status(status, settings, "maximized")
end

setmetatable(M, {
	__index = function(_, k)
		error('Invalid command "' .. k .. '"')
	end,
})

return M
