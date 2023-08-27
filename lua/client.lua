#!nvim.exe --clean --headless -l

-- must be run with the flags in the shebang
local SCRIPT_PATH = vim.v.argv[5]
SCRIPT_PATH = vim.fs.normalize(vim.fn.fnamemodify(SCRIPT_PATH, ":h"))
package.path = package.path .. ";" .. SCRIPT_PATH .. "/?.lua"

local uv = vim.loop
---@module "settings"
local settings = require("settings").client

---@module "utils.parser"
local parser = require("utils.parser")

---@module "utils.named_pipes"
local named_pipes = require("utils.named_pipes")

---@module "utils.commands"
local commands = require("utils.commands")

---@type command
settings.command = "status"
settings.query = "get_status"
settings.params = {
	pipe_name = "string",
	query = "string",
	command = "string",
}

settings = parser.parse_settings(vim.v.argv, settings) --[[@as client_settings]]

named_pipes.create_client({
	pipe_name = settings.pipe_name,
	request = settings.query,
	timeout = settings.timeout,
	default = vim.json.encode(settings.default),
	format = "json",
	callback = function(_, raw_status)
		local status = assert(vim.json.decode(raw_status))
		commands[settings.command](status, settings)
	end,
})

uv.run("default")
