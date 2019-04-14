-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "player.playersManager"
-- in any script using the functions.

local globals = require "main.globals"

local M = {}
local playersIDs = {}

-- Set active playersIDs
function M.setActivePlayersIDs(newPlayersIDs)
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

-- Get unhashed playersIDs
function M.getActivePlayersIDs()
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

-- Get all players positions
function M.getPlayersPos()
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

-- Get closes player ID to position given
function M.getClosestPlayerID(pos)
	local playersPos = M.getPlayersPos()

	if playersIDs ~= 0 then
		local closestPlayerID = playersIDs[1]
		local distanceToClosestPlayer = vmath.length(playersPos[1] - pos)

		for i, playerPos in pairs(playersPos) do 
			local distanceToCurrentPlayer = vmath.length(playerPos - pos)

			if distanceToCurrentPlayer < distanceToClosestPlayer then
				closestPlayerID = playersIDs[i]
				distanceToClosestPlayer = vmath.length(playerPos - pos)
			end
		end
		return closestPlayerID
	else
		return 0
	end
end

-- Get player position of given ID
function M.getPlayerPos(id)
	local scriptUrl = msg.url(nil, id, "player")
	local playerPos = go.get(scriptUrl, "position")
	return playerPos
end

return M