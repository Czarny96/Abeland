-- gennerates session pattern

local M = {}

s_SessionCounter = 0


--- Creates a new session
function M.create()
	
	local function isGameOver()
		return false
	end

	local session = {}
	
	--- Starts the session 
	-- @return success
	-- @return error_message
	function session.start()
		
		--Creating session ID
		s_SessionCounter = s_SessionCounter + 1
		session.sessionID = s_SessionCounter
		print("Creating a new session with ID: " .. session.sessionID)
		
		local ok, err = pcall(function()
			--TODO: check what pcall does
		end)
		
		return true
	end

	-- ends session and releases resources
	function session.destroy()
		--Add code here to clean up session
		print("Destroying session with ID: " .. session.sessionID)
		session = nil
	end


	function session.functionSkeleton()

	end

	function session.update()
		--check if game over
		if isGameOver() then
			session.destroy()
		end
		return session
	end

	return session.update()
end

return M
