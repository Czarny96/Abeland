local globals = require "main.globals"

local M = {}
local animTimer = 0

function M.init()
	local url = msg.url("main",go.get_id(),"player")
	label.set_text("#label_hp", go.get(url, "health"))
	local startPos = go.get_position()	
	go.set(url, "isKilled", true)
	globals.setArePlayersDead(false)
	go.set(url, "position", vmath.vector3(startPos.x, startPos.y, 0.99))
	go.set_position(go.get(url, "position"))
end

function M.manageFlagsAndTimers(dt)
	local url = msg.url("main",go.get_id(),"player")
	--Vulnerability flag
	if go.get(url, "nonVulnerableTimer") <= 0 then
		go.set(url, "isVulnerable", true)
	end

	--Collider correction
	go.set(url, "wallCollisionCorrector", vmath.vector3())

	--Timers
	go.set(url, "nonVulnerableTimer", go.get(url, "nonVulnerableTimer") - dt)
	go.set(url, "nonOperativeTimer", go.get(url, "nonOperativeTimer") - dt)
end

function M.messages(message_id, message, sender)
	local url = msg.url("main",go.get_id(),"player")

	--Activating player
	if message_id == hash("start") then
		go.set_position(go.get_position("main:/spawnPoints/spawn_archer"))
		msg.post("#sprite", "play_animation", {id = hash("player_down")})
		sprite.set_constant("#sprite", "tint", vmath.vector4(1, 1, 1, 1))
		label.set_text("#label_hp", go.get(url, "health"))
		go.set(url, "isKilled", false)
		globals.setArePlayersDead(false)
		go.set(url, "nonVulnerableTimer", 0)
	elseif message_id == hash("stop") then
		go.set_position(go.get_position("main:/spawnPoints/players_room") + vmath.vector3(math.random(-128,128),0,0))
		go.set(url, "isKilled", true)
		go.set(url, "health", go.get(url, "maxHealth"))
	end

	if go.get(url, "isKilled") or go.get(url, "nonOperativeTimer") > 0 then
		if not globals.getArePlayersDead() then
			for i, player in pairs(globals.getPlayersURL()) do
				if not go.get(player, "isKilled") then
					globals.setArePlayersDead(false)
					return
				end
				globals.setArePlayersDead(true)
			end
			return
		end
	end
	--Movement
	if message_id == hash("move") then
		go.set(url, "movingDir", vmath.vector3(message.x, message.y, 0))

		if go.get(url, "movingDir").x ~= 0 or go.get(url, "movingDir").y ~= 0 then
			go.set(url, "isMoving", true)
		else
			go.set(url, "isMoving", false)
		end		
	end

	--Invulnerability (all enemy interactions put here)
	if go.get(url, "isVulnerable") then
		--Got Hit
		if message_id == hash("hit") then
			go.set(url, "health", go.get(url, "health") - message.dmg)
			label.set_text("#label_hp", go.get(url, "health"))
			go.set(url, "nonVulnerableTimer", 0.5)
			go.set(url, "isVulnerable", false)
		end
	end

	--AFK
	if message_id == hash("desactivate") then
		sprite.set_constant("#sprite", "tint", vmath.vector4(1, 1, 1, 0.33))
		go.set(url, "isVulnerable", false)
		go.set(url, "nonVulnerableTimer", 999)

		--Activate if player came back
	elseif message_id == hash("activate") then
		go.set(url, "nonVulnerableTimer", 50)
		go.set(url, "isVulnerable", false)
		go.set(url, "nonOperativeTimer", 2)
		sprite.set_constant("#sprite", "tint", vmath.vector4(1, 1, 1, 1))
		msg.post("#sprite", "play_animation", {id = hash("player_afk")})
	end

	--Colliders
	if message_id == hash("contact_point_response") then	
		-- Get the info needed to move out of collision. We might
		-- get several contact points back and have to calculate
		-- how to move out of all of them by accumulating a
		-- correction vector for this frame:
		if message.distance > 0 then
			-- First, project the accumulated correction onto
			-- the penetration vector
			local proj = vmath.project(go.get(url, "wallCollisionCorrector"), message.normal * message.distance)
			if proj < 1 then
				-- Only care for projections that does not overshoot.
				local comp = (message.distance - message.distance * proj) * message.normal
				-- Apply compensation
				go.set_position(go.get_position() + comp)
				-- Accumulate correction done
				go.set(url, "wallCollisionCorrector", go.get(url, "wallCollisionCorrector") + comp)
			end
		end
	end

	--Kill
	if message_id == hash("kill") then
		go.delete()
	end


end

function M.updateAnimation(dt)
	local url = msg.url("main",go.get_id(),"attack")
	if go.get(url, "isShooting") then
		animTimer = 0.3
	end

	if animTimer >= 0 then
		local vector = go.get(url, "shootingDir")
		if vector.x < -0.3 then
			if vector.y > 0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_att_up_left")})
			elseif vector.y < -0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_att_down_left")})
			else
				msg.post("#sprite", "play_animation", {id = hash("player_att_left")})
			end
		elseif vector.x > 0.3 then
			if vector.y > 0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_att_up_right")})
			elseif vector.y < -0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_att_down_right")})
			else
				msg.post("#sprite", "play_animation", {id = hash("player_att_right")})
			end
		elseif vector.y > 0.3  then
			msg.post("#sprite", "play_animation", {id = hash("player_att_up")})
		elseif vector.y < -0.3  then
			msg.post("#sprite", "play_animation", {id = hash("player_att_down")})
		end
	else
		url = msg.url("main",go.get_id(),"player")
		local vector = go.get(url, "movingDir")
		if vector.x < -0.3 then
			if vector.y > 0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_up_left")})
			elseif vector.y < -0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_down_left")})
			else
				msg.post("#sprite", "play_animation", {id = hash("player_left")})
			end
		elseif vector.x > 0.3 then
			if vector.y > 0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_up_right")})
			elseif vector.y < -0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_down_right")})
			else
				msg.post("#sprite", "play_animation", {id = hash("player_right")})
			end
		elseif vector.y > 0.3  then
			msg.post("#sprite", "play_animation", {id = hash("player_up")})
		elseif vector.y < -0.3  then
			msg.post("#sprite", "play_animation", {id = hash("player_down")})
		end
	end
	animTimer = animTimer - dt
end

function M.move(vector, dt)
	M.updateAnimation(dt)
	local playerPos = go.get_position()
	local url = msg.url("main",go.get_id(),"player")
	playerPos = playerPos + vector * go.get(url,"movingSpeed") * dt
	go.set_position(playerPos)
	go.set("#player", "position", go.get_position())
end

function M.death(dt)
	local url = msg.url("main",go.get_id(),"player")
	if not go.get(url, "isKilled") then
		go.set(url, "isKilled", true)
		msg.post("#sprite", "play_animation", {id = hash("player_killed")})
		msg.post("#death_sound", "play_sound", {gain = 0.5})
		go.set(url, "killedTimer", 5)
		local position = go.get(url, "position")
		go.set_position(vmath.vector3(position.x, position.y, -0.97))
	else
		go.set(url, "killedTimer", go.get(url, "killedTimer") - dt)
		if go.get(url, "killedTimer") <= 0 then
			go.delete()
		end
	end
end

return M