local globals = require "main.globals"
local playersManager = require "managers.playersManager"
local bodyManager = require "managers/bodyManager.bodyManager"

local M = {}
local animTimer = 0

function M.init(self)
	self.isKilled = false
	self.informedAboutBeingKilled = false
	label.set_text("#label_hp", self.health)
	go.set_position(self.position)
end

function M.manageFlagsAndTimers(self, dt)
	--Vulnerability flag
	if self.nonVulnerableTimer <= 0 then
		self.isVulnerable = true
	end

	--Collider correction
	self.wallCollisionCorrector = vmath.vector3()

	--Timers
	self.nonVulnerableTimer = self.nonVulnerableTimer - dt
	self.nonOperativeTimer = self.nonOperativeTimer - dt
end

function M.messages(self, message_id, message, sender)
	local url = msg.url("main",go.get_id(),"player")

	--Activating player
	if message_id == hash("start") then
		msg.post("#sprite", "play_animation", {id = hash("player_down")})
		sprite.set_constant("#sprite", "tint", vmath.vector4(1, 1, 1, 1))
		
		--self.position = go.get_position(url)
		self.health = self.maxHealth
		self.isKilled = false
		self.informedAboutBeingKilled = false
		self.nonVulnerableTimer = 0
		
		label.set_text("#label_hp", self.health)
		go.set_position(self.position)
		playersManager.setActivePlayersIDs()

	elseif message_id == hash("stop") then
		playersManager.setActivePlayersIDs()
		go.delete()
	end

	if message_id == hash("revive") and self.isKilled then
		bodyManager.deleteEternalBody(self.class)
		msg.post("#sprite", "play_animation", {id = hash("player_down")})
		sprite.set_constant("#sprite", "tint", vmath.vector4(1, 1, 1, 1))

		self.health = self.maxHealth
		self.isKilled = false
		self.informedAboutBeingKilled = false
		self.nonVulnerableTimer = 0
		
		go.set_position(self.position)
		label.set_text("#label_hp", self.health)
		msg.post("/TCP_server/go#TCP_server_gui", "playerRessurected",{playerID=go.get_id()})

	end
	
	if (self.isKilled or self.nonOperativeTimer > 0) and self.informedAboutBeingKilled == false then
		self.informedAboutBeingKilled = true
		msg.post("/TCP_server/go#TCP_server_gui", "playerDied",{playerID=go.get_id()})
		for i, player in pairs(playersManager.getActivePlayersIDs()) do
			local url = msg.url(nil,player,"player")
			if not go.get(url, "isKilled") then
				return
			end
		end
		msg.post("/TCP_server/go#TCP_server_gui", "playersAreDead")
		return
	end
	--Movement
	if message_id == hash("move") then
		self.movingDir = vmath.vector3(message.x, message.y, 0)

		if self.movingDir.x ~= 0 or self.movingDir.y ~= 0 then
			self.isMoving = true
		else
			self.isMoving = false
		end		
	end

	--Invulnerability (all enemy interactions put here)
	if self.isVulnerable then
		--Got Hit
		if message_id == hash("hit") then
			self.health = self.health - message.dmg
			label.set_text("#label_hp", self.health)
			self.nonVulnerableTimer =  0.5
			self.isVulnerable = false
		end
	end

	--AFK
	if message_id == hash("desactivate") then
		sprite.set_constant("#sprite", "tint", vmath.vector4(1, 1, 1, 0.33))
		self.isVulnerable = false
		self.nonOperativeTimer = 999
		playersManager.setActivePlayersIDs()
	--Activate if player came back
	elseif message_id == hash("activate") then
		sprite.set_constant("#sprite", "tint", vmath.vector4(1, 1, 1, 1))
		msg.post("#sprite", "play_animation", {id = hash("player_afk")})
		
		self.nonVulnerableTimer = 50
		self.isVulnerable = false
		self.nonOperativeTimer = 2
		playersManager.setActivePlayersIDs()
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
			local proj = vmath.project(self.wallCollisionCorrector, message.normal * message.distance)
			if proj < 1 then
				-- Only care for projections that does not overshoot.
				local comp = (message.distance - message.distance * proj) * message.normal
				-- Apply compensation
				go.set_position(go.get_position() + comp)
				-- Accumulate correction done
				self.wallCollisionCorrector = self.wallCollisionCorrector + comp
			end
		end
	end

	--Kill
	if message_id == hash("kill") then
		go.delete()
	end


end

function M.updateAnimation(self, dt)
	local url = msg.url("main", go.get_id(), "attack")
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
		if self.movingDir.x < -0.3 then
			if self.movingDir.y > 0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_up_left")})
			elseif self.movingDir.y < -0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_down_left")})
			else
				msg.post("#sprite", "play_animation", {id = hash("player_left")})
			end
		elseif self.movingDir.x > 0.3 then
			if self.movingDir.y > 0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_up_right")})
			elseif self.movingDir.y < -0.3 then
				msg.post("#sprite", "play_animation", {id = hash("player_down_right")})
			else
				msg.post("#sprite", "play_animation", {id = hash("player_right")})
			end
		elseif self.movingDir.y > 0.3  then
			msg.post("#sprite", "play_animation", {id = hash("player_up")})
		elseif self.movingDir.y < -0.3  then
			msg.post("#sprite", "play_animation", {id = hash("player_down")})
		end
	end
	animTimer = animTimer - dt
end

function M.move(self, dt)
	M.updateAnimation(self, dt)
	local playerPos = go.get_position()
	playerPos = playerPos + self.movingDir * self.movingSpeed * dt
	go.set_position(playerPos)
	self.position = go.get_position()

end

function M.death(self, dt)
	if not self.isKilled then
		self.isKilled = true
		msg.post("#sprite", "play_animation", {id = hash("player_killed")})
		msg.post("#death_sound", "play_sound", {gain = 0.5})	
		--Creates body of a player
		bodyManager.createEternalBody(self.position, self.class)
		--Set player position out of arena (temporarily, because it can be revived)
		go.set_position(vmath.vector3(math.random(-10000,-9000),-1000,0))
	end
end

return M