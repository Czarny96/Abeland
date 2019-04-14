-- gennerates session pattern

local M = {}

s_SessionCounter = 0


--- Creates a new session
function M.create()
	local session = {}

	--Creating session ID
	s_SessionCounter = s_SessionCounter + 1
	session.sessionID = s_SessionCounter
	print("Creating a new session with ID: " .. session.sessionID)
	
	local function localFunctionSkeleton()
	end

	--- Starts the session 
	-- @return success
	-- @return error_message
	function session.start()
		
		local ok, err = pcall(function()
			--TODO: check what pcall does
		end)
		
		return true
	end

	-- ends session and releases resources
	function session.destroy()

	end


	function server.functionSkeleton()

	end

	function session.update()
		--corutine skeleton
		coroutine.wrap(function()

		end)


	end

	return session
end

return M
