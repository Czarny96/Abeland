-- gennerates session pattern

local M = {}



--- Creates a new session
function M.create()
	--assert(on_data, "You must provide an on_data function")

	print("Creating a new session")

	local session = {}

	local function localFunctionSkeleton()
	end

	--- Starts the session 
	-- @return success
	-- @return error_message
	function session.start()
		print("Starting TCP server on port " .. port)
		local ok, err = pcall(function()
			--TODO: check what pcall does
		end)
		if err then
			print("Unable to start session", err)
			return false, err
		end
		return true
	end

	-- ends session and releases resources
	function session.destroy()

	end


	function server.functionSkeleton()

	end



	--- Update the TCP socket server. This will resume all
	-- the spawned coroutines in order to check for new
	-- clients and data on existing clients
	function session.update()
		--if not server_socket then
		--return
		--end


		--corutine skeleton
		coroutine.wrap(function()

		end)


	end

	return session
end

return M
