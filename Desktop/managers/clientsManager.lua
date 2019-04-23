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

function M.getAllPlayers()
	return playersTable
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


local function setPlayerNick(nick,playerIP)
	playersTable[playerIP][5] = nick
end

local function lockPlayerClass(class,playerIP)
	playersTable[playerIP][6] = class
	playersTable[playerIP][2] = "/player_" .. class
end


function M.getPlayerID(playerIP)
	return playersTable[playerIP][2]
end

function M.setPlayerReadines(playerIP, readiness)
	playersTable[playerIP][7] = readiness
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

function M.resetPlayersToDefault()
	for ip,values in pairs(playersTable) do
		playersTable[ip] = {playersTable[ip][1],"",0.0,true,"","", false}
	end
end

function M.addPlayer(playerIP,client)
	if amountOfCurrentPlayers < ALLOWED_MAX_PLAYERS then 
		-- key: playerIP 
		-- values:
		-- 1 - client; 2 - class url; 3 - inactivity time counter; 
		-- 4 - is player inactive?;  5 - nick; 6 - class; 7 - is player ready
		--TODO: Think about prevention of calling object without url
		if playersTable[playerIP] == nil then
			playersTable[playerIP] = {client,"",0.0,true,"","", false}
			amountOfCurrentPlayers = amountOfCurrentPlayers + 1 
		end
	end
end

function M.removePlayer(playerIP)
	mountOfCurrentPlayers = amountOfCurrentPlayers - 1 
	translationLayer.RemovePlayerObject(M.getPlayerID(playerIP))
	playersTable[playerIP] = nil
end

function M.addNickToPlayer(frame,playerIP)
	nick = translationLayer.getNickFromFrame(frame)
	setPlayerNick(nick,playerIP)
end

local function checkIfClassAvaible(class)
	local isAvaible = true

	for ip,values in pairs(playersTable) do
		if values[6] == class then
			isAvaible = false
		end	
	end
	
	return isAvaible
end

function M.tryToLockPlayerClass(frame,playerIP)

	class = translationLayer.getClassFromFrame(frame)
	local success = false
	
	if checkIfClassAvaible(class) then
		lockPlayerClass("",playerIP)
		lockPlayerClass(class,playerIP)
		success = true
	end
	
	return success
end

function M.getPlayerClass(playerIP)
	return playersTable[playerIP][6]
end

function M.getPlayerNick(playerIP)
	return playersTable[playerIP][5]
end

function M.sendClassToMenu(playerIP)
	local dataPack = {}
	table.insert(dataPack, {ip=playerIP, playerClass=M.getPlayerClass(playerIP)}) 
	translationLayer.passPlayerClass(dataPack)

end

function M.sendNickToMenu(playerIP)
	local dataPack = {}
	table.insert(dataPack, {ip=playerIP, playerNickname=M.getPlayerNick(playerIP)}) 
	translationLayer.passPlayerNick(dataPack)
end

function M.areAllPlayersReady()
	local answer = true
	for ip,values in pairs(playersTable) do
		if values[7] == false then
			answer = false
		end
	end
	return answer

end

return M

