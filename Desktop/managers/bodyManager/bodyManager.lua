-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "managers/bodyManager.bodyManagers"
-- in any script using the functions.

local M = {}

local bodyCreatorUrl = "main:/bodyCreator#bodyCreator"

-- Table with all eternal(player's) bodies IDs
local eternalBodyTable = {}

-- Add normal body with timer
function M.createTimedBody(position, bodyType, dissapearTimer)
	msg.post(bodyCreatorUrl, "createTimedBody", {pos = position, isEternal = false, timer = dissapearTimer, type = bodyType})
end

-- Add eternal body to bodyTable
function M.addEternalBody(ID, class)
	local body = {bodyID = ID, type = class}
	table.insert(eternalBodyTable, body)
end

-- Create eternal body via bodyCreator
function M.createEternalBody(position, bodyType)
	msg.post(bodyCreatorUrl, "createEternalBody", {pos = position, isEternal = true, type = bodyType})
end

-- Delete eternal body from table and game
function M.deleteEternalBody(class)
	local bodies = eternalBodyTable
	for i, body in pairs(bodies) do
		if body.type == class then
			msg.post(body.bodyID, "delete")
			table.remove(eternalBodyTable, i)
			return
		end
	end	
end

-- Delete all eternal bodies from table and game
function M.deleteAllEternalBodies()
	local bodies = eternalBodyTable
	for i, body in pairs(bodies) do
		msg.post(body.bodyID, "delete")
		table.remove(eternalBodyTable, i)
	end
end

return M