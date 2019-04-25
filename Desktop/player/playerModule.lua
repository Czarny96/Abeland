

local M = {}


function M.init()
	local url = msg.url("main",go.get_id(),"player")
	label.set_text("#label_hp", go.get(url, "health"))
	local startPos = go.get_position()	
	go.set(url, "position", vmath.vector3(startPos.x, startPos.y, 0.99))
	go.set_position(go.get(url, "position"))
end

function M.manageFlagsAndTimers(dt)
	local url = msg.url("main",go.get_id(),"player")
	--Vulnerability flag
	if go.get(url, "nonVulnerableTimer") <= 0 then
		go.set(url, "isVulnerable", true)
	end
	--Collider flags
	go.set(url, "wallsColliderTop", false)
	go.set(url, "wallsColliderBottom", false)
	go.set(url, "wallsColliderLeft", false)
	go.set(url, "wallsColliderRight", false)

	--Timers
	go.set(url, "nonVulnerableTimer", go.get(url, "nonVulnerableTimer") - dt)
	go.set(url, "nonOperativeTimer", go.get(url, "nonOperativeTimer") - dt)
end

function M.messages(message_id, message, sender)
	local url = msg.url("main",go.get_id(),"player")
	
	if go.get(url, "isKilled") or go.get(url, "nonOperativeTimer") > 0 then
		print("DEAD")
		return
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
		--Walls
		if message.group == hash("walls") or message.group == hash("walls") then
			if sender.fragment == hash("wallsTopCollider") then
				go.set(url, "wallsColliderTop", true)
			elseif sender.fragment == hash("wallsBottomCollider") then
				go.set(url, "wallsColliderBottom", true)
			end

			if sender.fragment == hash("wallsLeftCollider") then
				go.set(url, "wallsColliderLeft", true)
			elseif sender.fragment == hash("wallsRightCollider") then
				go.set(url, "wallsColliderRight", true)
			end
		end
	end

	--Activating player
	if message_id == hash("start") then
		go.set_position(go.get_position("main:/spawnPoints/spawn_archer"))
	elseif message_id == hash("stop") then
		go.set_position(go.get_position("main:/spawnPoints/players_room") + vmath.vector3(-128,0,0))
	end

	--Kill
	if message_id == hash("kill") then
		go.delete()
	end
end

function M.manageCollisions()
	local url = msg.url("main",go.get_id(),"player")
	if (go.get(url, "wallsColliderTop") and go.get(url, "movingDir").y > 0) or (go.get(url, "wallsColliderBottom") and go.get(url, "movingDir").y < 0) then
		go.set(url, "movingDir.y", 0)
	end
	if (go.get(url, "wallsColliderLeft") and go.get(url, "movingDir").x < 0) or (go.get(url, "wallsColliderRight") and go.get(url, "movingDir").x > 0) then
		go.set(url, "movingDir.x", 0)
	end
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

function M.move(vector, dt)
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

	local playerPos = go.get_position()
	local url = msg.url("main",go.get_id(),"player")
	playerPos = playerPos + vector * go.get(url,"movingSpeed") * dt
	go.set_position(playerPos)
	go.set("#player", "position", go.get_position())
end

return M