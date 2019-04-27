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

--This arrays keep track of all enemies in the wainting_room
local inactiveRangeEnemiesIDs = {}
local inactiveMaleeEnemiesIDs = {}

--This arrays keep track of all enemies actively being on arena
local activeRangeEnemiesIDs = {}
local activeMaleeEnemiesIDs = {}

--Variable for random number
local rand

--Important objects URLs
local wave_label = "main:/gameContent#label_waveNr"
local waiting_room = vmath.vector3(750,-1500,0)
local gate_top_out = vmath.vector3(928,1400,0)
local gate_bottom_out = vmath.vector3(928,-320,0)
local gate_left_out = vmath.vector3(-320,540,0)
local gate_right_out = vmath.vector3(2240,540,0)

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

function M.initializeEnemies(amount)
	--This function creates all enemy objects and puts them in the waiting_room
	local enemyRanged
	local enemyMalee

	for i = 0, amount/2, 1 do
		enemyRanged = factory.create("main:/spawnPoints/waiting_room#enemyMageFactory")
		enemyMalee = factory.create("main:/spawnPoints/waiting_room#enemyMaleeFactory")

		msg.post(enemyRanged, "setInactive")
		msg.post(enemyMalee, "setInactive")

		table.insert(inactiveRangeEnemiesIDs, enemyRanged)
		table.insert(inactiveMaleeEnemiesIDs, enemyMalee)
	end
end

function M.isWaveOver()
		--This function checks if a wave is over / finished / all enemies are dead / inactive
	if next(activeMaleeEnemiesIDs) == nil and next(activeRangeEnemiesIDs) == nil then
		globals.setIsWaveOver(true)
		return true
	else
		print("WAVE STILL GOING")
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
		print("WAVE STILL GOING")
	end
end

function M.setEnemyInactive(enemyID)
	--This function sets given enemy (enemyID) to inactive state, resurrecting and teleporting to the wainting_room
	msg.post(enemy, "setInactive")
	go.set_position(globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), enemyID)

	if M.isActiveEnemyRanged(enemyID) then
		table.remove(activeRangeEnemiesIDs, M.findIndexOfEnemy(activeRangeEnemiesIDs,enemyID))
		table.insert(inactiveRangeEnemiesIDs, enemyID)
	else
		table.remove(activeMaleeEnemiesIDs, M.findIndexOfEnemy(activeMaleeEnemiesIDs,enemyID))
		table.insert(inactiveMaleeEnemiesIDs, enemyID)
	end

	if M.isWaveOver() then
		M.startNextWave()
	end
end

function M.findIndexOfEnemy(tab,enemy)
	--This function helps to find an index of specified enemyObject in given array
	for i, value in pairs(activeRangeEnemiesIDs) do
		if value == enemy then 
			return i
		end
	end
end

function M.isActiveEnemyRanged(enemy)
	--This function checks if given enemyObject type is ranged (true) or malee (false)
	for i, value in pairs(activeRangeEnemiesIDs) do
		if value == enemy then 
			return true
		end
	end
	return false
end

function M.resetArena()
	--This function resets all enemies and wave counter to default (inactive, 1)
	for i, enemy in pairs(activeRangeEnemiesIDs) do
		M.setEnemyInactive(enemy)
	end
	activeRangeEnemiesIDs = {}

	for i, enemy in pairs(activeMaleeEnemiesIDs) do
		M.setEnemyInactive(enemy)
	end
	activeMaleeEnemiesIDs = {}

	globals.setWaveNr(1)
end


function M.initializeWave(rangePercent, gateAmount)
	--Teleports enemies to arena (behind gates / to gate_[direction]_out
	--rangePercent == what is a ratio of ranged attack enemies to malee attacking enemies 
	--gateAmount == to how many of 4 gates enemies should be distributed
	print("INITIALIZE WAVE:", globals.getWaveNr())
	local enemiesAmount = globals.getWaveNr()
	local gateSide
	-- info for session generator to know that wave has started
	globals.setIsWaveOver(false)

	--Set wave number counter on main screen
	label.set_text(wave_label, "Wave: " .. globals.getWaveNr())
	globals.setWaveNr(globals.getWaveNr()+1)

	if gateAmount <= 1 then
		--Spawn enemies only at top gate
		msg.post("/topWalls#topWallsScript", "openTop")
		for i = 1, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			if rand <= rangePercent then
				msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_top_out.x, y = gate_top_out.y, gate = "top"})
				table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
			else
				msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_top_out.x, y = gate_top_out.y, gate = "top"})
				table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
			end
		end


	elseif gateAmount == 2 then
		--Spawn enemies only at top & bottom gate
		msg.post("/topWalls#topWallsScript", "openTop")
		msg.post("/walls#wallsScript", "openBottom")
		for i = 1, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if gateSide <= 50 then
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_top_out.x, y = gate_top_out.y, gate = "top"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_top_out.x, y = gate_top_out.y, gate = "top"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
				end
			else
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_bottom_out.y, gate = "bottom"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_bottom_out.y, gate = "bottom"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
				end
			end
		end
	elseif gateAmount == 3 then
		--Spawn enemies at top, bottom & left gate
		msg.post("/topWalls#topWallsScript", "openTop")
		msg.post("/walls#wallsScript", "openBottom")
		msg.post("/walls#wallsScript", "openLeft")

		for i = 1, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if gateSide <= 33 then
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_top_out.x, y = gate_top_out.y, gate = "top"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_top_out.x, y = gate_top_out.y, gate = "top"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
				end
			elseif gateSide <= 66 then
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_bottom_out.y, gate = "bottom"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_bottom_out.y, gate = "bottom"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
				end
			else
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_bottom_out.y, gate = "left"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_bottom_out.y, gate = "left"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
				end
			end
		end
	elseif gateAmount >= 4 then
		--Spawn enemies at all gates
		msg.post("/topWalls#topWallsScript", "openTop")
		msg.post("/walls#wallsScript", "openBottom")
		msg.post("/walls#wallsScript", "openLeft")
		msg.post("/walls#wallsScript", "openRight")

		for i = 1, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if gateSide <= 25 then
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_top_out.x, y = gate_top_out.y, gate = "top"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_top_out.x, y = gate_top_out.y, gate = "top"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
				end
			elseif gateSide <= 50 then
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_bottom_out.y, gate = "bottom"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_bottom_out.y, gate = "bottom"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
				end
			elseif gateSide <= 75 then
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_left_out.y, gate = "left"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_left_out.y, gate = "left"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])
				end
			else
				if rand <= rangePercent then
					msg.post(inactiveRangeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_right_out.y, gate = "right"})
					table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i])
				else
					msg.post(inactiveMaleeEnemiesIDs[i], "setActive", { x = gate_bottom_out.x, y = gate_right_out.y, gate = "right"})
					table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i])

				end
			end
		end
	end
	
	for k, active in pairs(activeMaleeEnemiesIDs) do
		for i, inactive in pairs(inactiveMaleeEnemiesIDs) do
			if active == inactive then
				table.remove(inactiveMaleeEnemiesIDs, k)
				break
			end
		end
	end
	
	for k, active in pairs(activeRangeEnemiesIDs) do
		for i, inactive in pairs(inactiveRangeEnemiesIDs) do
			if active == inactive then
				table.remove(inactiveRangeEnemiesIDs, k)
				break
			end
		end
	end
end

return M
