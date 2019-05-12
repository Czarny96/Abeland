-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.

local M = {}

local globals = require "main.globals"
local playersManager = require "managers.playersManager"

local enemyIDs = {}

--Variable for random number
local rand

--Important objects URLs
local wave_label = "main:/gameContent#label_waveNr"

local gate_top_enemies = 0;
local gate_bottom_enemies = 0;
local gate_left_enemies = 0;
local gate_right_enemies = 0;

function M.closeAllGates()
	msg.post("/topWalls#topWallsScript", "closeTop")
	msg.post("/walls#wallsScript", "closeBottom")
	msg.post("/walls#wallsScript", "closeLeft")
	msg.post("/topWalls#topWallsScript", "closeLeft")
	msg.post("/walls#wallsScript", "closeRight")
	msg.post("/topWalls#topWallsScript", "closeRight")
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

function M.resetAllEnemyPushers()
	msg.post("main:/enemyPusher#enemyPusherScript", "reset")
	msg.post("main:/enemyPusher1#enemyPusherScript", "reset")
	msg.post("main:/enemyPusher2#enemyPusherScript", "reset")
	msg.post("main:/enemyPusher3#enemyPusherScript", "reset")
end

function M.enableEnemyPushers()
	msg.post("main:/enemyPusher#enemyPusherScript", "waveStart")
	msg.post("main:/enemyPusher1#enemyPusherScript", "waveStart")
	msg.post("main:/enemyPusher2#enemyPusherScript", "waveStart")
	msg.post("main:/enemyPusher3#enemyPusherScript", "waveStart")
end

function M.startNextWave()
	--Starts new wave
	if globals.getWaveNr() < 5 then
		M.initializeWave(1)
	elseif globals.getWaveNr() < 10 then
		M.initializeWave(2)
	elseif globals.getWaveNr() < 15 then
		M.initializeWave(3)
	else
		M.initializeWave(4)
	end
	M.enableEnemyPushers()
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


function M.initializeWave(gateAmount)
	math.randomseed(15478517)
	local enemyTypesAmount = 5
	--Teleports enemies to arena (behind gates / to gate_[direction]_out
	--rangePercent == what is a ratio of ranged attack enemies to malee attacking enemies 
	--gateAmount == to how many of 4 gates enemies should be distributed
	print("Initializing wave nr", globals.getWaveNr())
	local enemiesAmount = 3 * globals.getWaveNr() + 2
	local gateSide
	-- info for session generator to know that wave has started
	msg.post("/TCP_server/go#TCP_server_gui", "waveWasOver")

	--Set wave number counter on main screen
	label.set_text(wave_label, "Wave: " .. globals.getWaveNr())
	globals.setWaveNr(globals.getWaveNr() + 1)

	if gateAmount <= 1 then
		--Spawn enemies only at top gate
		msg.post("/topWalls#topWallsScript", "openTop")
		
		for i = 1, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			if rand % enemyTypesAmount == 0 then
				table.insert(enemyIDs, factory.create("/enemyFactory#skeletonMageFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
			elseif rand % enemyTypesAmount == 1 then
				table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
			elseif rand % enemyTypesAmount == 2 then
				table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
			elseif rand % enemyTypesAmount == 3 then
				table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
			elseif rand % enemyTypesAmount == 4 then
				table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
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
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			else
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
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
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			elseif gateSide <= 66 then
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			else
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
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
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[1] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			elseif gateSide <= 50 then
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[2] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			elseif gateSide <= 75 then
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[3] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			else
				if rand % enemyTypesAmount == 0 then
					table.insert(enemyIDs, factory.create("/enemyFactory#mageFactory", globals.getSpawnPoints()[4] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 1 then
					table.insert( enemyIDs, factory.create("/enemyFactory#zombieFactory", globals.getSpawnPoints()[4] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 2 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonMeleeFactory", globals.getSpawnPoints()[4] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 3 then
					table.insert( enemyIDs, factory.create("/enemyFactory#skeletonArcherFactory", globals.getSpawnPoints()[4] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				elseif rand % enemyTypesAmount == 4 then
					table.insert( enemyIDs, factory.create("/enemyFactory#ghostFactory", globals.getSpawnPoints()[4] + vmath.vector3(math.random(-100,100),math.random(-100,100),0)))
				end
			end
		end
	end
	
end

return M
