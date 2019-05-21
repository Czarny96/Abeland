-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "main.globals"
-- in any script using the functions.

local M = {}

--spawnPoints
local gate_top_out = vmath.vector3(928,1400,0)
local gate_bottom_out = vmath.vector3(928,-320,0)
local gate_left_out = vmath.vector3(-320,540,0)
local gate_right_out = vmath.vector3(2240,540,0)

--player spell cooldowns
local archerCD = {yellow = 5, red = 9, green = 15, blue = 1}
local knightCD = {yellow = 10, red = 8, green = 8, blue = 1}
local mageCD = {yellow = 10, red = 12, green = 10, blue = 1}
local rogueCD = {yellow = 15, red = 10, green = 5, blue = 1}


--Wave counter for gameplay
local waveNumber = 1

--Pause indicator
local pause = false

local isWaveOver = false

function M.getCD(class) 
	if class == "archer" then
		return archerCD
	elseif class == "knight" then
		return knightCD
	elseif class == "mage" then
		return mageCD
	elseif class == "rogue" then
		return rogueCD
	end

	return nil
end

function M.getPlayersURL()
	return playersURL
end

function M.setIsWaveOver(booleanValue)
	isWaveOver = booleanValue
end

function M.getIsWaveOver()
	return isWaveOver
end

function M.getSpawnPoints()
	local spawnPoints = {gate_top_out, gate_bottom_out, gate_left_out, gate_right_out}
	return spawnPoints;
end

--waveNumber getter
function M.getWaveNr()
	return waveNumber
end
--waveNumber setter
function M.setWaveNr(waveNr)
	waveNumber = waveNr
end

--pause getter
function M.getPause()
	return pause
end

--pause setter
function M.setPause(state)
	--state => boolean
	pause = state
end


-- Get hash as string
function M.unhash(hash)
	return string.sub(tostring(hash), 8, #tostring(hash)-1)
end

return M
