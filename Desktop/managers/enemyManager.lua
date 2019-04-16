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
local waiting_room = "main:/spawnPoints/gate_right_out"
local gate_top_out = "main:/spawnPoints/gate_top_out"
local gate_top_in = "main:/spawnPoints/gate_top_in"
local gate_bottom_out = "main:/spawnPoints/gate_bottom_out"
local gate_bottom_in = "main:/spawnPoints/gate_bottom_in"
local gate_left_out = "main:/spawnPoints/gate_left_out"
local gate_left_in = "main:/spawnPoints/gate_left_in"
local gate_right_out = "main:/spawnPoints/gate_right_out"
local gate_right_in = "main:/spawnPoints/gate_right_in"

function M.initializeEnemies(amount)
	--This function creates all enemy objects and puts them in the waiting_room
	local enemyRanged
	local enemyMalee
	for i = 0, amount/2, 1
	do
		enemyRanged = factory.create("#enemyMageFactory")
		enemyMalee = factory.create("#enemyMaleeFactory")

		go.set_position(go.get_position(waiting_room) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), enemyRanged)
		go.set_position(go.get_position(waiting_room) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), enemyMalee)
		
		table.insert(inactiveRangeEnemiesIDs, enemyRanged)
		table.insert(inactiveMaleeEnemiesIDs, enemyMalee)
	end

	for i, enemy in pairs(inactiveRangeEnemiesIDs)
	do
		msg.post(enemy,"setInactive")
	end

	for i, enemy in pairs(inactiveMaleeEnemiesIDs)
	do
		msg.post(enemy,"setInactive")
	end
end

function M.isWaveOver()
--This function checks if a wave is over / finished / all enemies are dead / inactive
	if activeMaleeEnemiesIDs == {} and activeRangeEnemiesIDs == {} then
		--Starts new wave
		M.initializeWave(10, 1)
	end
end

function M.setEnemyInactive(enemyID)
--This function sets given enemy (enemyID) to inactive state, resurrecting and teleporting to the wainting_room
	msg.post(enemy, "setInactive")
  
	go.set_position(go.get_position(waiting_room) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), enemyID)

	if M.isActiveEnemyRanged(enemyID) then
		table.remove(activeRangeEnemiesIDs, M.findIndexOfEnemy(activeRangeEnemiesIDs,enemyID))
		table.insert(inactiveRangeEnemiesIDs, enemyID)
	else
		table.remove(activeMaleeEnemiesIDs, M.findIndexOfEnemy(activeMaleeEnemiesIDs,enemyID))
		table.insert(inactiveMaleeEnemiesIDs, enemyID)
	end
	
	M.isWaveOver()
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
	for i, enemy in pairs(activeRangeEnemiesIDs)
	do
		M.setEnemyInactive(enemy)
	end
	activeRangeEnemiesIDs = {}
	
	for i, enemy in pairs(activeMaleeEnemiesIDs)
	do
		M.setEnemyInactive(enemy)
	end
	activeMaleeEnemiesIDs = {}
	
	globals.setWaveNr(1)
end


function M.initializeWave(rangePercent, gateAmount)
--Teleports enemies to arena (behind gates / to gate_[direction]_out
	--rangePercent == what is a ratio of ranged attack enemies to malee attacking enemies 
	--gateAmount == to how many of 4 gates enemies should be distributed

	local enemiesAmount = globals.getWaveNr() * 20
	local gateSide

	--Set wave number counter on main screen
	label.set_text(wave_label, "Wave: " .. globals.getWaveNr())
	globals.setWaveNr(globals.getWaveNr()+1)
	
	if gateAmount <= 1 then
		--Spawn enemies only at top gate
		for i = 0, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			if rand <= rangePercent then
				go.set_position(go.get_position(gate_top_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i+1])
				table.remove(inactiveRangeEnemiesIDs, i+1)
			else
				go.set_position(go.get_position(gate_top_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i+1])
				table.remove(inactiveMaleeEnemiesIDs, i+1)
			end
		end
	elseif gateAmount == 2 then
		--Spawn enemies only at top & bottom gate
		for i = 0, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if rand <= rangePercent then
				if gateSide <= 50 then
					go.set_position(go.get_position(gate_top_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position(gate_bottom_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				end
				table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i+1])
				table.remove(inactiveRangeEnemiesIDs,i+1)
			else
				if gateSide <= 50 then
					go.set_position(go.get_position(gate_top_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position(gate_bottom_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				end
				table.insert(activeMaleeEnemiesIDs,inactiveMaleeEnemiesIDs[i+1])
				table.remove(inactiveMaleeEnemiesIDs,i+1)
			end
		end
	elseif gateAmount == 3 then
		--Spawn enemies at top, bottom & left gate
		for i = 0, enemiesAmount, 1
		do
			
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if rand <= rangePercent then
				if gateSide <= 33 then
					go.set_position(go.get_position(gate_top_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				elseif gateSide <= 66 then
					go.set_position(go.get_position(gate_bottom_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position(gate_left_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				end
				table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i+1])
				table.remove(inactiveRangeEnemiesIDs,i+1)
			else
				if gateSide <= 33 then
					go.set_position(go.get_position(gate_top_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				elseif gateSide <= 66 then
					go.set_position(go.get_position(gate_bottom_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position(gate_left_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				end
				table.insert(activeMaleeEnemiesIDs,inactiveMaleeEnemiesIDs[i+1])
				table.remove(inactiveMaleeEnemiesIDs,i+1)
			end
		end
	elseif gateAmount >= 4 then
		--Spawn enemies at all gates
		for i = 0, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			gateSide = math.floor(math.random(1,100))
			if rand <= rangePercent then
				if gateSide <= 25 then
					go.set_position(go.get_position(gate_top_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				elseif gateSide <= 50 then
					go.set_position(go.get_position(gate_bottom_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				elseif gateSide <= 75 then
					go.set_position(go.get_position(gate_left_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position(gate_right_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveRangeEnemiesIDs[i+1])
				end
				table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i+1])
				table.remove(inactiveRangeEnemiesIDs, i+1)
			else
				if gateSide <= 25 then
					go.set_position(go.get_position(gate_top_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				elseif gateSide <= 50 then
					go.set_position(go.get_position(gate_bottom_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100),0), inactiveMaleeEnemiesIDs[i+1])
				elseif gateSide <= 75 then
					go.set_position(go.get_position(gate_left_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position(gate_right_out) + vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0), inactiveMaleeEnemiesIDs[i+1])
				end
				table.insert(activeMaleeEnemiesIDs, inactiveMaleeEnemiesIDs[i+1])
				table.remove(inactiveMaleeEnemiesIDs, i+1)
			end
		end


	
	end

	for i, enemy in pairs(activeRangeEnemiesIDs)
	do
		msg.post(enemy, "setActive")
	end

	for i, enemy in pairs(activeMaleeEnemiesIDs)
	do
		msg.post(enemy, "setActive")
	end


	--Somehow waiting_room gets teleported with enemies so i set its position back to where it belongs
	go.set_position(vmath.vector3(750,-1500,0), "main:/spawnPoints/waiting_room")
--                              ,|
--                             //|                              ,|
--                            //,/                             -~ |
--                           // / |                         _-~   /  ,
--                          /'/ / /                       _-~   _/_-~ |
--                         ( ( / /'                   _ -~     _-~ ,/'
--                          \~\/'/|             __--~~__--\ _-~  _/,
--                  ,,)))))));, \/~-_     __--~~  --~~  __/~  _-~ /
--               __))))))))))))));,>/\   /        __--~~  \-~~ _-~
--              -\(((((''''(((((((( >~\/     --~~   __--~' _-~ ~|
--     --==//////((''  .     `)))))), /     ___---~~  ~~\~~__--~
--             ))| @    ;-.     (((((/           __--~~~'~~/
--             ( `|    /  )      )))/      ~~~~~__\__---~~__--~~--_
--                |   |   |       (/      ---~~~/__-----~~  ,;::'  \         ,
--                o_);   ;        /      ----~~/           \,-~~~\  |       /|
--                      ;        (      ---~~/         `:::|      |;|      < >
--                     |   _      `----~~~~'      /      `:|       \;\_____//
--               ______/\/~    |                 /        /         ~------~
--              /~;;.____/;;'  /          ___----(   `;;;/
--             / //  _;______;'------~~~~~    |;;/\    /
--            //  | |                        /  |  \;;,\
--           (<_  | ;                      /',/-----'  _>
--            \_| ||_                     //~;~~~~~~~~~
--                `\_|                   (,~~
--                                        \~\
end

return M