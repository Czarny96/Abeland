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

function M.getPlayerID(playerIP)
	local playerID = nil

	if playersTable[playerIP] ~= nil then
		playerID = playersTable[playerIP][2]
	end
	
	return playerID
end

function M.setPlayerID(playerID,playerIP)
	if playersTable[playerIP] ~= nil then
		playersTable[playerIP][2] = playerID
	end
end

function M.returnAllClients()
	local clients = {}
	for ip,values in pairs(playersTable) do
		clients[ip] = values[1]
	end
	return clients 
end

function M.isPlayerActive(playerIP)
	local answer = false 
	if playersTable[playerIP] ~= nil then
		answer = playersTable[playerIP][4]
	end
	return answer
end

function M.activatePlayer(playerIP)
	if playersTable[playerIP] ~= nil then
		translationLayer.activatePlayer(M.getPlayerID(playerIP))
		playersTable[playerIP][4] = true
	end
end

function M.desactivatePlayer(playerIP)
	if playersTable[playerIP] ~= nil then
		translationLayer.desactivatePlayer(M.getPlayerID(playerIP))
		playersTable[playerIP][4] = false
	end
end

function M.isAnyPlayer()
	return  amountOfCurrentPlayers > 0
end

function M.resetPlayerInactivityTimeCounter(playerIP)
	if playersTable[playerIP] ~= nil then
		playersTable[playerIP][3] = 0.0
	end
end

function M.incrementPlayerInactivityTimeCounterByDT(playerIP,dt)
	if playersTable[playerIP] ~= nil then
		playersTable[playerIP][3] = playersTable[playerIP][3] + dt
	end
end

function M.getPlayerInactivityTimeCounter(playerIP)
	local inactivityCounter = 0.0
	if playersTable[playerIP] ~= nil then
		inactivityCounter = playersTable[playerIP][3]
	end
	return inactivityCounter
end



local function lockPlayerClass(class,playerIP)
	if playersTable[playerIP] ~= nil then
		playersTable[playerIP][6] = class
	end
end

function M.setPlayerReadines(playerIP, readiness)
	if playersTable[playerIP] ~= nil then
		playersTable[playerIP][7] = readiness
	end
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
	if playersTable[playerIP] ~= nil then
		translationLayer.translateFrameToPlayer(data, M.getPlayerID(playerIP))
	end
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
		-- 1 - client; 2 - playerID; 3 - inactivity time counter; 
		-- 4 - is player active?;  5 - nick; 6 - class; 7 - is player ready
		--TODO: Think about prevention of calling object without url
		if playersTable[playerIP] == nil then
			playersTable[playerIP] = {client,"",0.0,true,"","", false}
			amountOfCurrentPlayers = amountOfCurrentPlayers + 1 
		end
	end
end

function M.removePlayer(playerIP)
	if playersTable[playerIP] ~= nil then
		amountOfCurrentPlayers = amountOfCurrentPlayers - 1 
		translationLayer.RemovePlayerObject(M.getPlayerID(playerIP))
		playersTable[playerIP] = nil
	end
end

local function setPlayerNick(nick,playerIP)
	if playersTable[playerIP] ~= nil then
		playersTable[playerIP][5] = nick
	end
end


function M.addNickToPlayer(frame,playerIP)
	if playersTable[playerIP] ~= nil then
		local nick = translationLayer.getNickFromFrame(frame)
		setPlayerNick(nick,playerIP)
	end
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
	local class = nil
	if playersTable[playerIP] ~= nil then
		class= playersTable[playerIP][6]
	end
	return class
end

function M.getPlayerNick(playerIP)
	local nick = nil
	if playersTable[playerIP] ~= nil then
		nick= playersTable[playerIP][5]
	end
	return nick
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

function M.clearNickFromMenu(playerIP)
	if playersTable[playerIP] ~= nil then
		translationLayer.clearPlayerNick(playerIP)
	end
end

function M.clearNicksFromMenu()
	translationLayer.clearPlayerNicks()
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

function M.getPlayerClientFromID(playerID)
	local client=nil
	for ip,values in pairs(playersTable) do
		if values[2] == playerID then
			client = values[1] 
		end
	end
	return client
end
return M

