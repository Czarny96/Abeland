-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.


-- THOU I COMMAND, THAT TRANSLATION LAYER SHALL BE STATELESS
-- Programer Genesis 1:2

local M = {}

function M.createPlayerObject(factoryReference, spawnLocation)
	print("Calling chosen factory")
	playerFactory = factoryReference
	
	print("Object Created")
	return factory.create(playerFactory,spawnLocation)
end

function M.RemovePlayerObject(objectID)
	print("Removing Player Object")
	--TODO: Inside palyer must be a part of code whtich allows to self destruction
end

function string:split(sep)
	local sep, fields = sep or ";", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function M.translateFrameToPlayer(frame, playerObjectID)
	movment = nil
	fields = frame:split()

	movmentX = tonumber(fields[1])
	movmentY = tonumber(fields[2])

	--Sending move command to playerObjet
	if movmentX ~= 0 or movmentY ~=0 then
		msg.post(playerObjectID, "move", {x = movmentX, y=movmentY})
	end
end

return M