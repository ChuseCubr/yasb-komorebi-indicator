local M = {}

---@alias argv string | boolean | number
---@alias type_converter fun(val: string, name: string): argv

---@type table<string, type_converter>
local convert_type = {}
function convert_type.boolean(val, name)
	local lookup = {
		["true"] = true,
		["1"] = true,
		["false"] = false,
		["0"] = false,
	}

	assert(type(lookup[val]) == "boolean", name .. " is not a boolean")
	return lookup[val]
end

function convert_type.string(val, _)
	return val
end

function convert_type.number(val, name)
	return assert(tonumber(val), name .. " is not a number")
end

---@alias params table<string, "string" | "boolean" | "number">

---@type fun(argv: string[], params: params): table<string, any>
function M.parse_args(argv, params)
	local args = {}

	for _, arg in ipairs(argv) do
		for param_name, type in pairs(params) do
			local param = "--" .. param_name .. "="
			param, _ = string.gsub(param, "_", "%%%-")
			local val, c = string.gsub(arg:lower(), param:lower(), "")
			if c == 1 then
				args[param_name] = convert_type[type](val, param_name)
				break
			end
		end
	end

	return args
end

---@class settings
---@field params params

---@param argv string[]
---@param settings settings
---@return settings | server_settings | client_settings
function M.parse_settings(argv, settings)
	local args = M.parse_args(argv, settings.params)
	for k, arg in pairs(args) do
		if arg then
			settings[k] = arg
		end
	end

	return settings
end

return M
