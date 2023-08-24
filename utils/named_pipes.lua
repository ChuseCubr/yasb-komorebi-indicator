local M = {}
local uv = vim.loop

---@alias callback fun(client: uv_pipe_t, chunk: string): boolean

---@alias formats
---| "string"
---| "json"

---@class server_opts
---@field pipe_name string
---@field callback callback
---@field format? formats
---@field default? string

---@param opts server_opts
function M.create_server(opts)
	---@type formats
	local format = opts.format or "string"

	---@type uv_pipe_t
	local server = assert(uv.new_pipe(false), "Failed to create server")
	local pipe_path = "\\\\.\\pipe\\" .. opts.pipe_name
	local _, err, _ = server:bind(pipe_path)
	assert(not err, err)

	---@type table<formats, callback>
	local verify_format = {
		string = function(_, _)
			return true
		end,

		json = function(client, chunk)
			local success, _ = pcall(vim.json.decode, chunk)
			if not success then
				client:write(opts.default or "Invalid request: Not in JSON format")
				return false
			end
			return true
		end,
	}

	server:listen(128, function(err)
		assert(not err, err)

		---@type uv_pipe_t
		local client = assert(uv.new_pipe(false))
		server:accept(client)
		client:read_start(function(err, chunk)
			assert(not err, err)
			if chunk then
				if not verify_format[format](client, chunk) then
					return
				end

				local success, err = pcall(opts.callback, client, chunk)
				if not success then
					client:write(opts.default or ("Internal server error: " .. err .. "\n"))
				end
			else
				client:shutdown()
				client:close()
			end
		end)
	end)
end

return M
