#!nvim.exe --clean --headless -l

-- must be run with the flags in the shebang
local SCRIPT_PATH = vim.v.argv[5]
SCRIPT_PATH = vim.fs.normalize(vim.fn.fnamemodify(SCRIPT_PATH, ":h"))
package.path = package.path .. ";" .. SCRIPT_PATH .. "/?.lua"

local uv = vim.loop
---@module "settings"
local settings = require("settings").client

settings.query = "get_status"
settings.params = {
	pipe_name = "string",
	query = "string",
}

---@module "utils.parser"
local parser = require("utils.parser")
settings = parser.parse_settings(vim.v.argv, settings) --[[@as client_settings]]

local named_pipes = require("utils.named_pipes")

named_pipes.create_client({
	pipe_name = settings.pipe_name,
	request = settings.query,
	timeout = settings.timeout,
	default = settings.default,
	format = "json",
	callback = function(client, chunk)
		io.write("Reply: " .. chunk)
	end,
})

uv.run("default")
