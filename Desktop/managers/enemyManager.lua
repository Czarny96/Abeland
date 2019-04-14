-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.

local M = {}

local globals = require "main.globals"

local inactiveRangeEnemiesIDs = {}
local inactiveMaleeEnemiesIDs = {}

local activeRangeEnemiesIDs = {}
local activeMaleeEnemiesIDs = {}

local rand

function M.initializeEnemies(amount)
	for i = 0, amount/2, 1
	do
		table.insert(inactiveRangeEnemiesIDs, factory.create("#enemyMaleeFactory"))
		table.insert(inactiveMaleeEnemiesIDs, factory.create("#enemyMageFactory"))
	end
end

function M.isWaveOver()
	if activeMaleeEnemiesIDs == {} and activeRangeEnemiesIDs == {} then
		M.resetArena()
	end
end

function M.setEnemyInactive(enemyID)
	go.set(enemyID, "health", go.get(enemyID, "maxHealth"))
	go.set_position(go.get_position("spawnPoints/waiting_room"), enemyID)

	if go.get(enemyID, "isRanged") == true then
		table.remove(activeRangeEnemiesIDs, enemyID)
		table.insert(inactiveRangeEnemiesIDs, enemyID)
	else
		table.remove(activeMaleeEnemiesIDs, enemyID)
		table.insert(inactiveMaleeEnemiesIDs, enemyID)
	end
end

--Sets all enemies as inactive and teleport them to waiting room
function M.resetArena()
	--Reset both tables so all enemies will be inactive again
	for i, enemy in pairs(activeRangeEnemiesIDs)
	do
		table.insert(inactiveRangeEnemiesIDs, enemy)
		go.set_position(go.get_position("spawnPoints/waiting_room"),enemy)
	end
	activeRangeEnemiesIDs = {}
	
	for i, enemy in pairs(activeMaleeEnemiesIDs)
	do
		table.insert(inactiveMaleeEnemiesIDs, enemy)
		go.set_position(go.get_position("spawnPoints/waiting_room"),enemy)
	end
	activeMaleeEnemiesIDs = {}
end

--Teleports enemies to arena (behind gates / to gate_[direction]_out
function M.initializeWave(rangePercent, gateAmount)
	--distancePercent == what is a ratio of ranged attack enemies to malee attacking enemies 
	--gateAmount == to how many of 4 gates enemies should be distributed

	local enemiesAmount = globals.getWaveNr() * 20
	local gateSide

	--Set wave number counter on main screen
	label.set_text("main:/gameContent#label_waveNr", "Wave: " .. globals.getWaveNr())
	globals.setWaveNr(globals.getWaveNr()+1)
	
	if gateAmount <= 1 then
		--Spawn enemies only at top gate
		for i = 0, enemiesAmount, 1
		do
			rand = math.floor(math.random(1,100))
			if rand <= rangePercent then
				go.set_position(go.get_position("/spawnPoints/gate_top_out"), inactiveRangeEnemiesIDs[i+1])
				table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i+1])
				table.remove(inactiveRangeEnemiesIDs,i+1)
			else
				go.set_position(go.get_position("/spawnPoints/gate_top_out"), inactiveMaleeEnemiesIDs[i+1])
				table.insert(activeMaleeEnemiesIDs,inactiveMaleeEnemiesIDs[i+1])
				table.remove(inactiveMaleeEnemiesIDs,i+1)
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
					go.set_position(go.get_position("/spawnPoints/gate_bottom_out"), inactiveRangeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position("/spawnPoints/gate_top_out"), inactiveRangeEnemiesIDs[i+1])
				end
								table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i+1])
				table.remove(inactiveRangeEnemiesIDs,i+1)
			else
				if gateSide <= 50 then
					go.set_position(go.get_position("/spawnPoints/gate_bottom_out"), inactiveMaleeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position("/spawnPoints/gate_top_out"), inactiveMaleeEnemiesIDs[i+1])
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
					go.set_position(go.get_position("/spawnPoints/gate_bottom_out"), inactiveRangeEnemiesIDs[i+1])
				elseif gateSide <= 66 then
					go.set_position(go.get_position("/spawnPoints/gate_top_out"), inactiveRangeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position("/spawnPoints/gate_left_out"), inactiveRangeEnemiesIDs[i+1])
				end
				table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i+1])
				table.remove(inactiveRangeEnemiesIDs,i+1)
			else
				if gateSide <= 33 then
					go.set_position(go.get_position("/spawnPoints/gate_bottom_out"), inactiveMaleeEnemiesIDs[i+1])
				elseif gateSide <= 66 then
					go.set_position(go.get_position("/spawnPoints/gate_top_out"), inactiveMaleeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position("/spawnPoints/gate_left_out"), inactiveMaleeEnemiesIDs[i+1])
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
					go.set_position(go.get_position("/spawnPoints/gate_bottom_out"), inactiveRangeEnemiesIDs[i+1])
				elseif gateSide <= 50 then
					go.set_position(go.get_position("/spawnPoints/gate_top_out"), inactiveRangeEnemiesIDs[i+1])
				elseif gateSide <= 75 then
					go.set_position(go.get_position("/spawnPoints/gate_left_out"), inactiveRangeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position("/spawnPoints/gate_right_out"), inactiveRangeEnemiesIDs[i+1])
				end
				table.insert(activeRangeEnemiesIDs, inactiveRangeEnemiesIDs[i+1])
				table.remove(inactiveRangeEnemiesIDs,i+1)
			else
				if gateSide <= 25 then
					go.set_position(go.get_position("/spawnPoints/gate_bottom_out"), inactiveMaleeEnemiesIDs[i+1])
				elseif gateSide <= 50 then
					go.set_position(go.get_position("/spawnPoints/gate_top_out"), inactiveMaleeEnemiesIDs[i+1])
				elseif gateSide <= 75 then
					go.set_position(go.get_position("/spawnPoints/gate_left_out"), inactiveMaleeEnemiesIDs[i+1])
				else
					go.set_position(go.get_position("/spawnPoints/gate_right_out"), inactiveMaleeEnemiesIDs[i+1])
				end
				table.insert(activeMaleeEnemiesIDs,inactiveMaleeEnemiesIDs[i+1])
				table.remove(inactiveMaleeEnemiesIDs,i+1)
			end
		end
	end


	--Somehow waiting_room gets teleported with enemies so i set its position back to where it belongs
	go.set_position(vmath.vector3(750,-1500,0), "/spawnPoints/waiting_room")
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