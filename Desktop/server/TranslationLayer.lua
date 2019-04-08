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
	msg.post(objectID, "kill")
end

function M.desactivatePlayer(objectID)
	print("Desactivating player"..objectID)
	msg.post(objectID, "desactivate")
end

function M.activatePlayer(objectID)
	print("Activating player"..objectID)
	msg.post(objectID, "activate")
end

function string:split(sep)
	local sep, fields = sep or ";", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function M.translateFrameToPlayer(frame, playerObjectID)
	movement = nil
	fields = frame:split()

	movementX = tonumber(fields[1])
	movementY = tonumber(fields[2])

	shootingX = tonumber(fields[3])
	shootingY = tonumber(fields[4])
	

	--Sending move command to playerObjet
	msg.post(playerObjectID, "move", {x = movementX, y = movementY})

	--Sending shoot command to playerObject
	if shootingX ~= 0 or shootingY ~=0 then
		msg.post(playerObjectID, "shoot", {x = shootingX, y = shootingY})
	end

	--Button interpretation
	button = tonumber(fields[5])
	if button == 1 then
		msg.post(playerObjectID, "btnBlue")
	elseif button == 2 then
		msg.post(playerObjectID, "btnGreen")
	elseif button == 3 then
		msg.post(playerObjectID, "btnRed")
	elseif button == 4 then
		msg.post(playerObjectID, "btnYellow")
	end
end

return M