-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "player.playersManager"
-- in any script using the functions.

local globals = require "main.globals"

local M = {}

-- This array keeps track of all active players ID
local playersIDs = {}

function M.setActivePlayersIDs(newPlayersIDs)
-- Set active playersIDs
	local newTable = {}
	for i, player in pairs(newPlayersIDs) do
		table.insert(newTable, player)
	end
	if #newTable > 0 then
		playersIDs = newTable
	else
		playersIDs = {}
	end
end

function M.getActivePlayersIDs()
-- Get unhashed playersIDs
	local alivePlayersTable = {}
	for i, player in pairs(playersIDs) do
		local scriptUrl = msg.url(nil, player, "player")
		if go.get(scriptUrl, "isKilled") == false then
			table.insert(alivePlayersTable, globals.unhash(player))
		end
	end
	if #alivePlayersTable > 0 then
		return alivePlayersTable
	else
		return 0
	end
end

function M.getPlayersPos()
-- Get all players positions
	local tableOfPlayersPos = {}
	if playersIDs ~= 0 then
		for i, player in pairs(playersIDs) do 
			local scriptUrl = msg.url(nil, player, "player")
			local playerPos = go.get(scriptUrl, "position")
			table.insert(tableOfPlayersPos, playerPos)
		end
		return tableOfPlayersPos
	else
		return 0
	end
end

function M.getClosestPlayerID(pos)
-- Get closes player ID to position given
	local playersPos = M.getPlayersPos()
	if #playersPos ~= 0 then
		local closestPlayerID = playersIDs[1]
		local distanceToClosestPlayer = math.pow((playersPos[1].x - pos.x), 2) + math.pow((playersPos[1].y - pos.y), 2)
		for i, playerPos in pairs(playersPos) do 
			local distanceToCurrentPlayer = math.pow((playersPos[i].x - pos.x), 2) + math.pow((playersPos[i].y - pos.y), 2)
			if distanceToCurrentPlayer < distanceToClosestPlayer then			
				distanceToClosestPlayer = distanceToCurrentPlayer
				closestPlayerID = playersIDs[i]
			end
		end
		return closestPlayerID
	else
		return 0
	end
end

function M.getPlayerPos(id)
-- Get player position of given ID
	local scriptUrl = msg.url(nil, id, "player")
	local playerPos = go.get(scriptUrl, "position")
	return playerPos
end

function M.setPlayerActive(class)
	msg.post( "main:/gameContent/player_" .. class, "")
	go.set_position(go.get_position("main:/spawnPoints/spawn_" .. class), "main:/gameContent/player_" .. class)
end

return M
