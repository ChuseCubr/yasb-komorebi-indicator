#!nvim.exe --clean --headless -l

-- must be run with the flags in the shebang
local SCRIPT_PATH = vim.v.argv[5]
SCRIPT_PATH = vim.fs.normalize(vim.fn.fnamemodify(SCRIPT_PATH, ":h"))
package.path = package.path .. ";" .. SCRIPT_PATH .. "/?.lua"

local uv = vim.loop
---@module "settings"
local settings = require("settings").server

settings.params = {
	input_pipe = "string",
	output_pipe = "string",
}

---@module "utils.parser"
local parser = require("utils.parser")
settings = parser.parse_settings(vim.v.argv, settings) --[[@as server_settings]]

---@alias status table<indicator, boolean>

---@class state
---@field notif string
---@field status status

---@type state
local state = {
	notif = "",
	status = {},
}

local named_pipes = require("utils.named_pipes")
named_pipes.create_server({
	pipe_name = settings.output_pipe,
	callback = function(client, chunk)
		io.write("Received request: ", chunk, "\n")
		client:write("Server settings: " .. vim.json.encode(settings) .. "\n")
	end,
	prerun = function()
		io.write("Listening at: ", settings.output_pipe, "\n")
	end,
})

uv.run("default")
