-- gennerates session pattern

local M = {}

s_SessionCounter = 0



--- Creates a new session
function M.create()

	
	

	local gameOverFlag = 0
	local session = {}
	
	--- Starts the session 
	-- @return success
	function session.setGameOverFlag(value)
		gameOverFlag = value
	end

	function session.isGameOver()
		if gameOverFlag == 1 then
			return true
		else
			return false
		end
	end
	
	function session.start()
		s_SessionCounter = s_SessionCounter + 1
		session.sessionID = s_SessionCounter
		session.setGameOverFlag(0)
		print("Creating a new session with ID: " .. session.sessionID)
		
		return true
	end

	-- ends session and releases resources
	function session.destroy()
		--Add code here to clean up session
		print("Destroying session with ID: " .. session.sessionID)
	end


	function session.update()
		--check if game over
		if isGameOver() then
			session.destroy()
		else
			
		end
	end

	return session
end

return M
