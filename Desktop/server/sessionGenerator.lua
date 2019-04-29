-- gennerates session pattern

local clientsManager = require "managers.clientsManager"
local playersManager = require "managers.playersManager"
local enemyManger = require "managers.enemyManager"
local globals = require "main.globals"

local M = {}

s_SessionCounter = 0


--- Creates a new session
function M.create()
	local gameOverFlag = 0
	local session = {}
	local playersQueue = {}


	function session.insertPlayerToQue(playerID)
		table.insert(playersQueue,playerID)
	end
	function session.isPlayerInQue(playerID)
		if #playersQueue > 0 then
			for i,id in ipairs(playersQueue) do
				if playersQueue[i] == id then
					return true
				end
			end
		end
		return false
	end
	
	function session.removePlayerInQue(playerID)
		for i,id in ipairs(playersQueue) do
			if playersQueue[i] == id then
				table.remove(playersQueue,i)
			end
		end
		
	end

	function session.setPlayersFromQue()
		for i,playerID in pairs(playersQueue) do
			playersManager.setPlayerToArena(playerID)
			table.remove(playersQueue,i)
		end
	end
	
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
		session.setGameOverFlag(0)
		s_SessionCounter = s_SessionCounter + 1
		session.sessionID = s_SessionCounter
		
		print("Creating a new session with ID: " .. session.sessionID)
		
		playersManager.setAllPlayersToArena()
		playersManager.setActivePlayersIDs()
		enemyManger.startNextWave()

		msg.post("/menu#championSelect", "startGame", {})
		
		return true
	end

	-- ends session and releases resources
	function session.destroy()
		--Add code here to clean up session
		print("Destroying session with ID: " .. session.sessionID)
		playersManager.setAllPlayersToWaitingRoom()
		enemyManger.resetArena()
		if session.isPlayerInQue() then
			playersQueue = nil
		end
		msg.post("/menu#gameOver", "enable", {})
		
	end


	function session.update()
		--check if game over
		if globals.getArePlayersDead() then
			print("All players are dead")
			session.setGameOverFlag(1)
		end
		
		if session.isGameOver() then
			session.destroy()
		elseif globals.getIsWaveOver() and #playersQueue > 0 then
			session.setPlayersFromQue()
			playersManager.setActivePlayersIDs()
		end
	end

	return session
end

return M
