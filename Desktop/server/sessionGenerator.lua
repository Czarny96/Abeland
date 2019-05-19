-- gennerates session pattern

local clientsManager = require "managers.clientsManager"
local playersManager = require "managers.playersManager"
local bodyManager = require "managers/bodyManager.bodyManager"
local enemyManger = require "managers.enemyManager"
local globals = require "main.globals"

local M = {}

s_SessionCounter = 0


--- Creates a new session
function M.create()
	local gameOverFlag = 0
	local session = {}
	local playersQueue = {}

	
	function session.insertPlayerToQue(playerIP,playerClass)
		playersQueue[playerIP] = playerClass
	end
	
	function session.isPlayerInQue(playerIP)
		local answer = false
		if playersQueue[playerIP] ~= nil then
			answer = true
		end
		
		return answer
	end
	
	function session.removePlayerInQue(playerIP)
		playersQueue[playerIP] = nil
		playersManager.setActivePlayersIDs()
	end
	function session.ressurectPlayers()
		playersManager.reviveDeadPlayers()
	end

	function session.setPlayersFromQue()
		for ip,class in pairs(playersQueue) do
			clientsManager.setPlayerID(playersManager.setPlayerToArena(clientsManager.getPlayerClass(ip)), ip)
			session.removePlayerInQue(ip)
		end
		playersManager.setActivePlayersIDs()
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

		bodyManager.deleteAllEternalBodies()
		session.setPlayersFromQue()
		playersManager.setActivePlayersIDs()
		enemyManger.startNextWave()

		msg.post("/menu#championSelect", "startGame", {})
		msg.post("/soundBox","play",{songName = "#fightTheme"})
		
		return true
	end

	-- ends session and releases resources
	function session.destroy()
		--Add code here to clean up session
		print("Destroying session with ID: " .. s_SessionCounter)
		--playersManager.setAllPlayersToWaitingRoom()
		enemyManger.resetArena()
		enemyManger.resetAllEnemyPushers()
		
		if session.isPlayerInQue() then
			playersQueue = nil
		end
		msg.post("/menu#gameOver", "enable", {})
		
	end
--TODO: Temporary, until cleaner solution will be found
	local deadTime = 0
	function session.update()
		if session.isGameOver() then
			session.destroy()
		end
	end

	return session
end

return M
