-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "server.clientsManager"
-- in any script using the functions.

local M = {}

local playersTable = {}
local ALLOWED_MAX_PLAYERS = 4
local amountOfCurrentPlayers = 0
local translationLayer = require "server.TranslationLayer"

function M.getAmountOfCurrentPlayers()
	return amountOfCurrentPlayers
end

function M.isPlayerActive(playerIP)
	return playersTable[playerIP][4] == true
end

function M.activatePlayer(playerIP)
	translationLayer.activatePlayer(M.getPlayerID(playerIP))
	playersTable[playerIP][4] = true
end

function M.desactivatePlayer(playerIP)
	translationLayer.desactivatePlayer(M.getPlayerID(playerIP))
	playersTable[playerIP][4] = false
end

function M.isAnyPlayer()
	return  amountOfCurrentPlayers > 0
end

function M.resetPlayerInactivityTimeCounter(playerIP)
	playersTable[playerIP][3] = 0.0
end

function M.incrementPlayerInactivityTimeCounterByDT(playerIP,dt)
	playersTable[playerIP][3] = playersTable[playerIP][3] + dt
end

function M.getPlayerInactivityTimeCounter(playerIP)
	return playersTable[playerIP][3]
end

function M.getPlayerID(playerIP)
	return playersTable[playerIP][2]
end

function M.returnActivePlayersIDs()
	local playerIDs = {}
	for ip,values in pairs(playersTable) do
		if M.isPlayerActive(ip) then
			playerIDs[ip] = M.getPlayerID(ip)
		end
	end
	return playerIDs
end

function M.returnActiveClients()
	local clients = {}
	for ip,values in pairs(playersTable) do
		if M.isPlayerActive(ip) then
			clients[ip] = values[1]
		end
	end
	return clients 
end

function M.translateDataToPlayer(data, playerIP)
	translationLayer.translateFrameToPlayer(data, M.getPlayerID(playerIP))
end

function M.addPlayer(playerIP,client)
	if amountOfCurrentPlayers < ALLOWED_MAX_PLAYERS then 
		-- WARNING: Temporally fixed to call one factory, until mechanism to chose class at the controller side is avaible
		factoryObjectID = translationLayer.createPlayerObject("go#archerFactory", vmath.vector3(147, 297, 0))
		-- key: playerIP values: 1 - client; 2 - factoryObjectID; 3 - inactivity time counter; 4 - is player inactive?; 
		playersTable[playerIP] = {client,factoryObjectID,0.0,true}
		amountOfCurrentPlayers = amountOfCurrentPlayers + 1 
	end
end

function M.removePlayer(playerIP)
	playersTable[playerIP] = nil
	mountOfCurrentPlayers = amountOfCurrentPlayers - 1 
	translationLayer.RemovePlayerObject(M.getPlayerID(playerIP))
end

return M