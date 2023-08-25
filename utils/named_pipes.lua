local M = {}
local uv = vim.loop

---@alias callback fun(client: uv_pipe_t, chunk: string): boolean | nil

---@alias format
---| "string"
---| "json"

---@class server_opts
---@field pipe_name string
---@field callback callback
---@field prerun? fun()
---@field format? format
---@field default? string

---@param opts server_opts
---@return uv_pipe_t
function M.create_server(opts)
	---@type format
	local format = opts.format or "string"

	---@type uv_pipe_t
	local server = assert(uv.new_pipe(false), "Failed to create server")
	local pipe_path = "\\\\.\\pipe\\" .. opts.pipe_name
	local _, err, _ = server:bind(pipe_path)
	assert(not err, err)

	---@type table<format, callback>
	local verify_format = {
		string = function(_, _)
			return true
		end,

		json = function(client, chunk)
			local success, _ = pcall(vim.json.decode, chunk)
			if not success then
				client:write(opts.default or "Invalid request: Not in JSON format\n")
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
					client:write(opts.default or debug.traceback("Internal server error: " .. err))
				end
			else
				client:shutdown()
				client:close()
			end
		end)
	end)

	if opts.prerun then
		opts.prerun()
	end

	return server
end

---@class client_opts
---@field pipe_name string
---@field callback callback
---@field request string | fun()
---@field timeout? number | boolean
---@field format? format
---@field default? string

---@param opts client_opts
---@return uv_pipe_t
function M.create_client(opts)
	---@type format
	local format = opts.format or "string"
	local timeout = opts.timeout or 1000
	if timeout == 0 then
		timeout = false
	end

	---@param val any
	---@param err? string
	---@param err_code? string
	local function custom_assert(val, err, err_code)
		if val then
			return val
		end
		if opts.default then
			io.write(opts.default, "\n")
			os.exit(0)
		end
		if err then
			io.write(debug.traceback(err_code and (err .. err_code) or err))
			os.exit(1)
		end
		io.write(debug.traceback("Assertion failed!"))
		os.exit(1)
	end

	---@type uv_pipe_t
	local client = custom_assert(uv.new_pipe(false), "Failed to create client")
	local pipe_path = "\\\\.\\pipe\\" .. opts.pipe_name

	---@type table<format, callback>
	local verify_format = {
		string = function(_, _)
			return true
		end,

		json = function(_, chunk)
			local success, _ = pcall(vim.json.decode, chunk)
			custom_assert(success, "Server error: Invalid reply (not in JSON format): " .. chunk)
			return true
		end,
	}

	client:connect(pipe_path, function(err)
		custom_assert(not err, "Error connecting to server: ", err)
		client:read_start(function(err, chunk)
			custom_assert(not err, "Error connecting to server: ", err)
			if chunk then
				if not verify_format[format](client, chunk) then
					return
				end

				local success, err = pcall(opts.callback, client, chunk)
				custom_assert(success, "Client error: ", err --[[@as string]])

				client:shutdown()
				client:close()
				os.exit(0)
			else
				client:shutdown()
				client:close()
			end
		end)

		if type(opts.request) == "string" then
			client:write(opts.request --[[@as string]])
		else
			opts.request()
		end
	end)

	if timeout then
		---@type uv_timer_t
		local timer = assert(uv.new_timer(), "Failed to create timer")
		timer:start(timeout --[[@as number]], 0, function()
			timer:stop()
			timer:close()
			client:shutdown()
			client:close()
			io.write("Server error: Timed out\n")
			os.exit(1)
		end)
	end

	return client
end

return M
