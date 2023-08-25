local M = {}

local yasb_pipe = "komorebi_window_indicator"
local timeout = 1000

---@class yasb_data
---@field label string
---@field label_alt string
---@field on_left string
---@field on_right string
---@field on_middle string

---@type yasb_data
local default = {
	label = "",
	label_alt = "",
	on_left = "",
	on_right = "",
	on_middle = "",
}

---@alias indicator "monocle" | "maximized" | "floating" | "stacked"
---@type indicator[]
local priority = { "monocle", "maximized", "floating", "stacked" }

---@alias indicators table<indicator, yasb_data>
local indicators = {
	floating = {
		label = "",
		label_alt = "",
		on_left = "komorebic toggle-float",
		on_right = "",
		on_middle = "",
	},
	stacked = {
		label = "󱟱",
		label_alt = "󱟱",
		on_left = "komorebic cycle-stack next",
		on_right = "komorebic cycle-stack previous",
		on_middle = "komorebic unstack",
	},
	monocle = {
		label = "󰘖",
		label_alt = "󰘖",
		on_left = "komorebic toggle-monocle",
		on_right = "",
		on_middle = "",
	},
	maximized = {
		label = "󰁌",
		label_alt = "󰁌",
		on_left = "komorebic toggle-maximize",
		on_right = "",
		on_middle = "",
	},
}

---@class server_settings: settings
---@field input_pipe string
---@field output_pipe string
---@field default? yasb_data
---@field priority indicator[]
---@field indicators table<indicator, yasb_data>
--
---@type server_settings
M.server = {
	input_pipe = "komorebi_listener",
	output_pipe = yasb_pipe,
	default = default,

	indicators = indicators,
	priority = priority,
}

---@class client_settings: settings
---@field pipe_name string
---@field default? yasb_data

---@type client_settings
M.client = {
	pipe_name = yasb_pipe,
	default = default,
	timeout = timeout,
}

return M
