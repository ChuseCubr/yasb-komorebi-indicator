local M = {}
local uv = vim.loop

---@alias callback fun(client: uv_pipe_t, chunk: string): boolean | nil

---@alias formats
---| "string"
---| "json"

---@class server_opts
---@field pipe_name string
---@field callback callback
---@field prerun? fun()
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
					client:write(opts.default or ("Internal server error: " .. err .. "\n"))
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
end

---@class client_opts
---@field pipe_name string
---@field callback callback
---@field query string | fun()
---@field format? formats
---@field default? string

---@param opts client_opts
function M.create_client(opts)
	---@type formats
	local format = opts.format or "string"

	function custom_assert(val, err, err_code)
		if val then
			return val
		end
		if opts.default then
			io.write(opts.default .. "\n")
			os.exit(0)
		end
		if err then
			io.write(err_code and (err .. err_code .. "\n") or (err .. "\n"))
			os.exit(1)
		end
		io.write("Assertion failed!\n")
		os.exit(1)
	end

	---@type uv_pipe_t
	local client = custom_assert(uv.new_pipe(false), "Failed to create client")
	local pipe_path = "\\\\.\\pipe\\" .. opts.pipe_name

	---@type table<formats, callback>
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
				custom_assert(success, "Client error: ", err)

				client:shutdown()
				client:close()
				os.exit(0)
			else
				client:shutdown()
				client:close()
			end
		end)

		if type(opts.query) == "string" then
			client:write(opts.query --[[@as string]])
		else
			opts.query()
		end
	end)
end

return M
