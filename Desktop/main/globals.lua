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
			table.insert(tableOfPlayersIDs, string.sub(tostring(player), 8, #tostring(player)-1))
		end
		return tableOfPlayersIDs
	else
		return 0
	end
end
