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
			local unhasedID = string.sub(tostring(player), 8, #tostring(player)-1)
			table.insert(tableOfPlayersIDs, unhasedID)
		end
		return tableOfPlayersIDs
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