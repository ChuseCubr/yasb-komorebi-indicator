#!nvim.exe --clean --headless -l

-- must be run with the flags in the shebang
local SCRIPT_PATH = vim.v.argv[5]
SCRIPT_PATH = vim.fs.normalize(vim.fn.fnamemodify(SCRIPT_PATH, ":h"))
package.path = package.path .. ";" .. SCRIPT_PATH .. "/?.lua"

local uv = vim.loop

---@module "settings"
local settings = require("settings").server

---@module "utils.parser"
local parser = require("utils.parser")

---@module "utils.named_pipes"
local named_pipes = require("utils.named_pipes")

---@module "utils.active_window"
local active_window = require("utils.active_window")

settings.params = {
	input_pipe = "string",
	output_pipe = "string",
}

settings = parser.parse_settings(vim.v.argv, settings) --[[@as server_settings]]

---@class state
---@field raw_notif string
---@field notif table
---@field status status
---@field data string

---@type state
local state = {
	raw_notif = "",
	notif = {},
	status = {},
	data = assert(vim.json.encode(settings.default)),
}

-- komorebi listener
named_pipes.create_server({
	pipe_name = settings.input_pipe,
	callback = function(_, chunk)
		state.raw_notif = chunk
	end,
})

-- request listener
named_pipes.create_server({
	pipe_name = settings.output_pipe,
	default = settings.default,
	callback = function(client, _)
		client:write(state.data)
	end,
})

-- actively update status instead of waiting for a request
---@type uv_timer_t
local timer = assert(uv.new_timer())
timer:start(0, settings.interval, function()
	state.notif = assert(vim.json.decode(state.raw_notif))
	state.status = active_window.get_status(state.notif.state)
	state.data = assert(vim.json.encode(state.status))
end)

io.write("Listening at: ", settings.output_pipe, "\n")
io.popen("komorebic subscribe " .. settings.input_pipe)

uv.run("default")
