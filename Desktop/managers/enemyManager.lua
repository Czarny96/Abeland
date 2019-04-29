-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.

local M = {}

local globals = require "main.globals"

--Enemies are split into two groups: range, malee
--Thats why we have:
--	4 arrays that helds enemy objects
--		2 of each kind 
--			1 for active 
--			1 for inactive

local enemyIDs = {}

--Variable for random number
local rand

--Important objects URLs
local wave_label = "main:/gameContent#label_waveNr"

local gate_top_enemies = 0;
local gate_bottom_enemies = 0;
local gate_left_enemies = 0;
local gate_right_enemies = 0;


function M.closeGate(gate)
	if gate == "top" then
		msg.post("/topWalls#topWallsScript", "closeTop")
	elseif gate == "bottom" then
		msg.post("/walls#wallsScript", "closeBottom")
	elseif gate == "left" then
		msg.post("/walls#wallsScript", "closeLeft")
	elseif gate == "right" then
		msg.post("/walls#wallsScript", "closeRight")
	end
end

function M.canCloseGate(gate)
	if gate == "top" then
		gate_top_enemies = gate_top_enemies - 1
		if gate_top_enemies <= 0 then
			M.closeGate(gate)
		end
	elseif gate == "bottom" then
		gate_bottom_enemies = gate_bottom_enemies - 1
		if gate_bottom_enemies <= 0 then
			M.closeGate(gate)
		end
	elseif gate == "left" then
		gate_left_enemies = gate_left_enemies - 1
		if gate_left_enemies <= 0 then
			M.closeGate(gate)
		end
	elseif gate == "right" then
		gate_right_enemies = gate_right_enemies - 1
		if gate_right_enemies <= 0 then
			M.closeGate(gate)
		end
	end
end

function M.isWaveOver()
		--This function checks if a wave is over / finished / all enemies are dead / inactive
	if next(enemyIDs) == nil then
		globals.setIsWaveOver(true)
		print("Wave is over", globals.getWaveNr())
		return true
	else
		return false
	end
end

function M.startNextWave()
	--Starts new wave
	if globals.getWaveNr() < 5 then
		M.initializeWave(10, 1)
	elseif globals.getWaveNr() < 10 then
		M.initializeWave(15, 2)
	elseif globals.getWaveNr() < 15 then
		M.initializeWave(20, 3)
	else
		M.initializeWave(25, 4)
	end
end

function M.removeEnemy(enemy)
	table.remove(enemyIDs, M.findIndexOfEnemy(enemy))

	if M.isWaveOver() then
		M.startNextWave()
	end
end

function M.findIndexOfEnemy(enemy)
	--This function helps to find an index of specified enemyObject in given array
	for i, value in pairs(enemyIDs) do
		if value == enemy then 
			return i
		end
	end
end

function M.resetArena()
	--This function resets all enemies and wave counter to default (inactive, 1)
	for i, enemy in pairs(enemyIDs) do
		msg.post(enemy, "kill")
	end
	enemyIDs = {}

	globals.setWaveNr(1)
end


function M.initializeWave(rangePercent, gateAmount)
	--Teleports enemies to arena (behind gates / to gate_[direction]_out
	--rangePercent == what is a ratio of ranged attack enemies to malee attacking enemies 
	--gateAmount == to how many of 4 gates enemies should be distributed
	print("Initializing wave nr", globals.getWaveNr())
	local enemiesAmount = globals.getWaveNr()
	local gateSide
	-- info for session generator to know that wave has started
	globals.setIsWaveOver(false)

	--Set wave number counter on main screen
	label.set_text(wave_label, "Wave: " .. globals.getWaveNr())
	globals.setWaveNr(globals.getWaveNr() + 1)

	if gateAmount <= 1 then
		--Spawn enemies only at top gate
		msg.post("/topWalls#topWallsScript", "openTop")
		for i = 1, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			if rand <= rangePercent then
				local url = msg.url("main","/gate_top_out","enemyMageFactory")
				table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
			else
				local url = msg.url("main","/gate_top_out","enemyMeleeFactory")
				table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
			end
		end
	elseif gateAmount == 2 then
		--Spawn enemies only at top & bottom gate
		msg.post("/topWalls#topWallsScript", "openTop")
		msg.post("/walls#wallsScript", "openBottom")
		for i = 1, enemiesAmount, 1 do
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if gateSide <= 50 then
				if rand <= rangePercent then
					local url = msg.url("main","/gate_top_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_top_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			else
				if rand <= rangePercent then
					local url = msg.url("main","/gate_bottom_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_bottom_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			end
		end
	elseif gateAmount == 3 then
		--Spawn enemies at top, bottom & left gate
		msg.post("/topWalls#topWallsScript", "openTop")
		msg.post("/walls#wallsScript", "openBottom")
		msg.post("/walls#wallsScript", "openLeft")

		for i = 1, enemiesAmount, 1 do
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if gateSide <= 33 then
				if rand <= rangePercent then
					local url = msg.url("main","/gate_top_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_top_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			elseif gateSide <= 66 then
				if rand <= rangePercent then
					local url = msg.url("main","/gate_bottom_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_bottom_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			else
				if rand <= rangePercent then
					local url = msg.url("main","/gate_left_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_left_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			end
		end
	elseif gateAmount >= 4 then
		--Spawn enemies at all gates
		msg.post("/topWalls#topWallsScript", "openTop")
		msg.post("/walls#wallsScript", "openBottom")
		msg.post("/walls#wallsScript", "openLeft")
		msg.post("/walls#wallsScript", "openRight")

		for i = 1, enemiesAmount, 1 do
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if gateSide <= 25 then
				if rand <= rangePercent then
					local url = msg.url("main","/gate_top_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_top_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			elseif gateSide <= 50 then
				if rand <= rangePercent then
					local url = msg.url("main","/gate_bottom_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_bottom_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			elseif gateSide <= 75 then
				if rand <= rangePercent then
					local url = msg.url("main","/gate_left_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_left_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			else
				if rand <= rangePercent then
					local url = msg.url("main","/gate_right_out","enemyMageFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[4] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				else
					local url = msg.url("main","/gate_right_out","enemyMeleeFactory")
					table.insert(enemyIDs, factory.create(url, globals.getSpawnPoints()[4] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			end
		end
	end

	print(#enemyIDs)
end

return M
