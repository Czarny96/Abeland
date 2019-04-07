-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.
-- Get unhashed playersIDs
function getPlayersIDs()
	local playersIDs = returnPlayersIDs()
	local tableOfPlayersIDs = {}

	if #returnPlayersIDs() > 0 then
		for i, player in pairs(playersIDs) do 
			local unhasedID = unhash(player)
			if go.get(unhasedID.."#player", "isKilled") == false then
				table.insert(tableOfPlayersIDs, unhasedID)
			end
		end
		if #tableOfPlayersIDs > 0 then
			return tableOfPlayersIDs
		else
			return 0
		end
	else
		return 0
	end
end

-- Get all players positions
function getPlayersPos()
	local playersIDs = getPlayersIDs()
	local tableOfPlayersPos = {}
	if playersIDs ~= 0 then
		for i, player in pairs(playersIDs) do 
			local playerPos = go.get(playersIDs[i].."#player", "position")
			table.insert(tableOfPlayersPos, playerPos)
		end
		return tableOfPlayersPos
	else
		return 0
	end
end

-- Get closes player ID to position given
function getClosestPlayerID(pos)
	local playersIDs = getPlayersIDs()
	local playersPos = getPlayersPos()
	
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
function getPlayerPos(id)
	local playerPos = go.get(id.."#player", "position")
	return playerPos
end

-- Get hash as string
function unhash(hash)
	return string.sub(tostring(hash), 8, #tostring(hash)-1)
end