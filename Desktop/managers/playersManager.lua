-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "player.playersManager"
-- in any script using the functions.
local clientsManager = require "managers.clientsManager"
local globals = require "main.globals"

local M = {}

local activePlayersIDs = {}


function M.reviveDeadPlayers()
	local activePlayersIDsTable = M.getActivePlayersIDs()
	for i, player in pairs(activePlayersIDsTable) do
		msg.post(player, "revive")
	end
end

local function buildPlayerFromFabric(class)
	local url = msg.url("main","/spawn", class)
	return factory.create(url)
end

function M.setActivePlayersIDs()
-- Set indexable table of active players
	local allPlayersByIP = clientsManager.getAllPlayers()
	activePlayersIDs = {}
	if clientsManager.getAmountOfCurrentPlayers() > 0 then
		for playerIP in pairs(allPlayersByIP) do
			if clientsManager.isPlayerActive(playerIP) then
				table.insert(activePlayersIDs, allPlayersByIP[playerIP][2])
			end
		end
	end
end

function M.getActivePlayersIDs()
-- Get table of active players
	return activePlayersIDs
end

function M.getPlayersPos()
-- Get all players positions
	local activePlayersIDsTable = M.getActivePlayersIDs()
	local activePlayersPos = {}
	if #activePlayersIDsTable > 0 then
		for i, playerID in pairs(activePlayersIDsTable) do
			local playerURL = msg.url(nil, playerID, "player")
			local playerPos = go.get(playerURL, "position")
			table.insert(activePlayersPos, playerPos)
		end
		return activePlayersPos
	else
		return 0
	end
end

function M.getClosestPlayerID(pos)
	-- Get closest, active and alive player ID to position given
	local activePlayersIDsTable = M.getActivePlayersIDs()
	local playersPos = M.getPlayersPos()
	if playersPos ~= 0 then
		local closestPlayerID = 0
		for i, playerID in pairs(activePlayersIDsTable) do
		local playerURL = msg.url(nil, playerID, "player")
			if go.get(playerURL, "isKilled") == false then
				closestPlayerID = activePlayersIDsTable[i]
				break
			end
		end
		if closestPlayerID ~= 0 then
			local distanceToClosestPlayer = math.pow((playersPos[1].x - pos.x), 2) + math.pow((playersPos[1].y - pos.y), 2)
			for i, playerPos in pairs(playersPos) do 
				local distanceToCurrentPlayer = math.pow((playersPos[i].x - pos.x), 2) + math.pow((playersPos[i].y - pos.y), 2)
				if distanceToCurrentPlayer < distanceToClosestPlayer then			
					distanceToClosestPlayer = distanceToCurrentPlayer
					local playerURL = msg.url(nil, activePlayersIDsTable[i], "player")
					local isPlayerKilled = go.get(playerURL, "isKilled")
					if isPlayerKilled == false then
						closestPlayerID = activePlayersIDsTable[i]
					end
				end
			end
		end
		return closestPlayerID
	else
		return 0
	end
end

function M.getPlayerPos(id)
	-- Get player position of given ID
	local playerURL = msg.url(nil, id, "player")
	local playerPos = go.get(playerURL, "position")
	return playerPos
end

function M.setAllPlayersToArena()
	for i, player in pairs(clientsManager.getAllPlayers()) do
		M.setPlayerToArena(player[2])
	end
end

function M.setAllPlayersToWaitingRoom()
	for i, player in pairs(clientsManager.getAllPlayers()) do
		M.setPlayerToWaitingRoom(player[2])
	end
end

function M.setPlayerToArena(class)
	return buildPlayerFromFabric(class)
end

function M.setPlayerToWaitingRoom(playerID)
	local playerURL = msg.url("main", playerID, "player")
	msg.post(playerURL, "stop")
end

return M
